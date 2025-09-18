import SwiftUI
import Combine
import SwiftData

// 视图模式枚举
enum CalendarViewMode: String, CaseIterable, Identifiable {
    case week = "周"
    case month = "月"
    case year = "年"
    var id: String { self.rawValue }
}

@MainActor
class AppViewModel: ObservableObject {
    // 视图状态
    @Published var selection: SidebarSelection? = .schedule
    @Published var calendarViewMode: CalendarViewMode = .week
    @Published var currentDate: Date = .now
    
    // Popover 状态
    @Published var isShowingAddPopover = false
    
    @Published var newEventStartDate: Date = .now
    @Published var newEventEndDate: Date = .now
    
    // Sheet 状态
    @Published var isShowingAddItemSheet = false
    @Published var itemToEdit: ScheduleItem?
    
    // 网络与数据状态
    @Published var scheduleURL: String = ""
    @Published var requiresAuthentication: Bool = false
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    
    // 提醒与错误
    @Published var alertMessage: String?
    @Published var isShowingAlert = false

    private var scheduleService = ScheduleService()
    private let eventKitService = EventKitService()

    // 导出到系统日历
    func exportToSystemCalendar(items: [ScheduleItem]) {
        guard !items.isEmpty else {
            showAlert(message: "没有可供导出的日程。")
            return
        }
        Task {
            let (successCount, failureCount) = await eventKitService.addEventsConcurrently(for: items)
            if successCount > 0 {
                showAlert(message: "成功导入 \(successCount) 个日程。\(failureCount > 0 ? "\(failureCount) 个失败。" : "")")
            } else {
                showAlert(message: "未能导入日程。请检查日历访问权限或日程信息。")
            }
        }
    }
    
    func showAlert(message: String) {
        self.alertMessage = message
        self.isShowingAlert = true
    }

    // 从教务系统加载数据并存入数据库
    func loadAndSaveSchedule(database: ModelContext) {
        isLoading = true
        Task {
            do {
                let fetchedCourses = try await scheduleService.fetchAndParseSchedule(
                    from: scheduleURL,
                    requiresAuth: requiresAuthentication,
                    username: username,
                    password: password
                )
                
                for course in fetchedCourses {
                    let courseName = course.name
                    let courseStartDate = course.startDate
                    let predicate = #Predicate<ScheduleItem> { $0.title == courseName && $0.startDate == courseStartDate }
                    var descriptor = FetchDescriptor(predicate: predicate)
                    descriptor.fetchLimit = 1
                    
                    if try database.fetch(descriptor).isEmpty {
                         let newItem = ScheduleItem(title: course.name, location: course.location, teacher: course.teacher, startDate: course.startDate, endDate: course.endDate)
                        database.insert(newItem)
                    }
                }
                
                try database.save()
                
                self.isLoading = false
                showAlert(message: "成功从网络获取并保存了 \(fetchedCourses.count) 条课程信息。")
                
            } catch {
                self.isLoading = false
                showAlert(message: "加载失败: \(error.localizedDescription)")
            }
        }
    }
}

