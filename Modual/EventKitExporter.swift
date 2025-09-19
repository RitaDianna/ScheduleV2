import EventKit
import SwiftUI

/// 使用 EventKit 将日程导出到系统日历的具体实现，包含了更完善的权限管理逻辑。
struct EventKitExporter: CalendarExporterProtocol {
    private let eventStore = EKEventStore()

    /// 实现协议规定的 export 方法，现在包含了完整的权限检查流程。
    func export(items: [ScheduleItem]) async -> (successCount: Int, failureCount: Int) {
        let authorizationStatus = EKEventStore.authorizationStatus(for: .event)

        switch authorizationStatus {
        case .authorized, .fullAccess:
            // 权限已授予，直接执行导入操作。
            return await performExport(items: items)
            
        case .notDetermined:
            // 用户从未被询问过，发起权限请求。
            if await requestAccess() {
                // 如果用户同意，则执行导入。
                return await performExport(items: items)
            } else {
                // 如果用户拒绝，则所有项目都算作失败。
                return (0, items.count)
            }
            
        case .denied, .restricted:
            // 权限已被用户明确拒绝或受系统限制。
            // 无法再次请求，只能提示用户去设置中修改。
            print("日历访问权限已被拒绝或受限。")
            // 在这种情况下，可以考虑让 ViewModel 显示一个更具体的提示。
            return (0, items.count)
            
        @unknown default:
            // 处理未来可能出现的新 case。
            return (0, items.count)
        }
    }
    
    /// 实际执行日历事件并发导入的核心函数。
    private func performExport(items: [ScheduleItem]) async -> (successCount: Int, failureCount: Int) {
        return await withTaskGroup(of: Bool.self, returning: (Int, Int).self) { group in
            for item in items {
                group.addTask {
                    let event = EKEvent(eventStore: self.eventStore)
                    event.title = item.title
                    event.location = item.location
                    event.notes = "\(item.teacher ?? "")"
                    event.startDate = item.startDate
                    event.endDate = item.endDate
                    event.calendar = self.eventStore.defaultCalendarForNewEvents
                    
                    do {
                        try self.eventStore.save(event, span: .thisEvent)
                        return true
                    } catch {
                        print("Failed to save event \(item.title): \(error)")
                        return false
                    }
                }
            }
            
            var successCount = 0
            for await didSucceed in group {
                if didSucceed { successCount += 1 }
            }
            
            return (successCount, items.count - successCount)
        }
    }

    /// 请求日历访问权限的核心函数。
    private func requestAccess() async -> Bool {
        do {
            if #available(macOS 14.0, *) {
                 return try await eventStore.requestFullAccessToEvents()
            } else {
                return try await eventStore.requestAccess(to: .event)
            }
        } catch {
            print("Request access error: \(error.localizedDescription)")
            return false
        }
    }
}

