
import EventKit

// EventKit 服务，用于处理所有与系统日历相关的操作
class EventKitService {
    private let eventStore = EKEventStore()

    // 请求日历访问权限
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

    // 使用 TaskGroup 并发处理日历事件导入
    func addEventsConcurrently(for items: [ScheduleItem]) async -> (successCount: Int, failureCount: Int) {
        guard await requestAccess() else { return (0, items.count) }

        return await withTaskGroup(of: Bool.self, returning: (Int, Int).self) { group in
            
            // 为每个日程创建一个并发任务
            for item in items {
                group.addTask {
                    // 每个任务都在自己的作用域内创建和保存事件
                    let event = EKEvent(eventStore: self.eventStore)
                    event.title = item.title
                    event.location = item.location
                    event.notes = "\(item.teacher ?? "")\n\(item.notes ?? "")"
                    event.startDate = item.startDate
                    event.endDate = item.endDate
                    event.calendar = self.eventStore.defaultCalendarForNewEvents
                    
                    do {
                        try self.eventStore.save(event, span: .thisEvent)
                        return true // 这个任务成功
                    } catch {
                        print("Failed to save event \(item.title): \(error)")
                        return false // 这个任务失败
                    }
                }
            }
            
            // 收集所有并发任务的结果
            var successCount = 0
            var failureCount = 0
            for await success in group {
                if success {
                    successCount += 1
                } else {
                    failureCount += 1
                }
            }
            
            return (successCount, failureCount)
        }
    }
}
