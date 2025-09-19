import SwiftData
import SwiftUI

/// 负责处理与日程相关的业务逻辑，例如从提供者获取数据并将其转换为可保存的格式。
@MainActor
class ScheduleViewModel: ObservableObject {
    @Published var alertMessage: String?
    @Published var isShowingAlert = false

    private let modelContext: ModelContext
    private let scheduleProvider: GetScheduleProtocol = GetScheduleFormWebService()
    private let calendarExporter: CalendarExporterProtocol = EventKitExporter()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// 使用来自专用设置视图模型中的设置来加载日程。
    func loadAndSaveSchedule(from settings: DataSourceSettingsViewModel) async {
        settings.isLoading = true
        // defer 确保在函数退出时，无论成功或失败，isLoading 都会被重置。
        defer { settings.isLoading = false }

        do {
            // 1. 从提供者获取轻量级的 `Course` 对象。
            let fetchedCourses = try await scheduleProvider.RetrievingAarsingHTML(
                from: settings.scheduleURL,
                requiresAuth: settings.requiresAuthentication,
                username: settings.username,
                password: settings.password
            )

            // 2. 将 `Course` 对象转换为受管理的 `ScheduleItem` 对象。
            for course in fetchedCourses {
                let newItem = ScheduleItem(
                    title: course.title,
                    location: course.location,
                    teacher: course.teacher,
                    startDate: course.startDate,
                    endDate: course.endDate
                )

                // 插入前检查是否存在重复项。
                if try !itemExists(newItem) {
                    modelContext.insert(newItem)
                }
            }

            try modelContext.save()
            showAlert(message: "成功获取并保存了 \(fetchedCourses.count) 门课程。")

        } catch {
            showAlert(message: "加载日程失败: \(error.localizedDescription)")
        }
    }

    /// 检查数据库中是否已存在等效的日程项目。
    private func itemExists(_ item: ScheduleItem) throws -> Bool {
        let title = item.title
        let startDate = item.startDate
        let predicate = #Predicate<ScheduleItem> { $0.title == title && $0.startDate == startDate }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        return try !modelContext.fetch(descriptor).isEmpty
    }

    /// 将所有日程项目导出到系统日历。
    func exportToSystemCalendar() async {
        do {
            let descriptor = FetchDescriptor<ScheduleItem>(sortBy: [SortDescriptor(\.startDate)])
            let itemsToExport = try modelContext.fetch(descriptor)

            guard !itemsToExport.isEmpty else {
                showAlert(message: "没有可供导出的日程。"); return
            }

            let (successCount, failureCount) = await calendarExporter.export(items: itemsToExport)

            if successCount > 0 {
                let failureMessage = failureCount > 0 ? " \(failureCount) 个失败。" : ""
                showAlert(message: "成功导入 \(successCount) 个项目。" + failureMessage)
            } else {
                showAlert(message: "导入项目失败。请检查日历权限。")
            }
        } catch {
            showAlert(message: "导出失败: \(error.localizedDescription)")
        }
    }

    private func showAlert(message: String) {
        alertMessage = message
        isShowingAlert = true
    }
}
