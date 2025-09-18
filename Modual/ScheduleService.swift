

import Foundation

// 网络服务，负责获取和解析课程数据
class ScheduleService {
    // 这是一个临时结构，仅用于网络层的数据解析
    struct Course {
        let name: String, location: String, teacher: String, startDate: Date, endDate: Date
    }

    func fetchAndParseSchedule(from urlString: String, requiresAuth: Bool, username: String, password: String) async throws -> [Course] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // ... 在这里应该是您真实的HTML解析逻辑 ...
        return parseMockData()
    }

    // 辅助函数：将模拟数据解析为带真实日期的课程
    private func parseMockData() -> [Course] {
        let mockRawData = [
            ("高级软件工程", "星期一 3-4节", "教B-201", "张伟"),
            ("编译原理", "星期二 1-2节", "科A-505", "李静"),
            ("计算机网络", "星期三 5-6节", "教C-110", "王磊"),
            ("操作系统", "星期五 7-8节", "实验楼-302", "赵秀英"),
            ("数据结构", "星期一 7-8节", "教A-101", "陈红"),
            ("大学体育", "星期四 3-4节", "体育馆", "刘强"),
            ("算法设计", "星期二 5-7节", "科A-303", "李静")
        ]

        var courses: [Course] = []
        let calendar = Calendar.current
        let today = Date()
        
        for item in mockRawData {
            if let parsed = parseTime(timeString: item.1, relativeTo: today, calendar: calendar) {
                courses.append(Course(name: item.0, location: item.2, teacher: item.3, startDate: parsed.start, endDate: parsed.end))
            }
        }
        return courses
    }

    // 辅助函数：将 "星期一 3-4节" 转换为真实的 Date 对象
    private func parseTime(timeString: String, relativeTo date: Date, calendar: Calendar) -> (start: Date, end: Date)? {
        let components = timeString.split(separator: " ")
        guard components.count == 2 else { return nil }

        let dayOfWeekStr = String(components[0])
        let slotStr = String(components[1])
        
        let weekdayMap: [String: Int] = ["星期日": 1, "星期一": 2, "星期二": 3, "星期三": 4, "星期四": 5, "星期五": 6, "星期六": 7]
        guard let targetWeekday = weekdayMap[dayOfWeekStr] else { return nil }

        let slotMap: [Int: (hour: Int, minute: Int)] = [
            1: (8, 0), 2: (8, 50), 3: (9, 50), 4: (10, 40), 5: (11, 30), 6: (14, 0), 7: (14, 50), 8: (15, 50), 9: (16, 40), 10: (18, 30), 11: (19, 20), 12: (20, 10)
        ]
        
        let slotComponents = slotStr.dropLast().split(separator: "-")
        guard slotComponents.count == 2, let startSlot = Int(slotComponents[0]), let endSlot = Int(slotComponents[1]) else { return nil }

        guard let startTimeInfo = slotMap[startSlot], let endTimeInfo = slotMap[endSlot] else { return nil }
        
        var startComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .hour, .minute, .second], from: date)
        startComponents.weekday = targetWeekday
        startComponents.hour = startTimeInfo.hour
        startComponents.minute = startTimeInfo.minute
        
        var endComponents = startComponents
        endComponents.hour = endTimeInfo.hour
        endComponents.minute = endTimeInfo.minute
        
        guard let startDate = calendar.date(from: startComponents),
              var endDate = calendar.date(from: endComponents) else { return nil }
        
        endDate = calendar.date(byAdding: .minute, value: 45, to: endDate)! // 每节课45分钟

        return (start: startDate, end: endDate)
    }
}
