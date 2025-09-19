import Foundation
import Cocoa

/**
 * `WebServiceScheduleProvider` 用于从Web服务器获取和解析课程数据
 *  Crreat by Kianna on 2025/09/18
 */
struct GetScheduleFormWebService: GetScheduleProtocol {
    /**
     * `fetch` 函数用于解析获取和解析HTML网页数据。
     * @param `url` 教务系统课程表展示链接。
     * @param `requiresAuth` 是否需要提供教务系统登录的账号和密码。
     * @param `username` 教务系统用户名。
     * @param `password` 教务系统密码。
     */
    func RetrievingAarsingHTML(from url: String, requiresAuth: Bool, username: String, password: String) async throws -> [CourseInformation] {
        // 开发笔记：2025/09/19
        // 测试网络延迟
        // 处理https的Get提交和Post提交两种方式
        // 获取教务系统课程表网站的HTML代码
        // 进行HTML解析
        // 存储课程数据到Coures结构体中
        // 返回诗句
        return parseMockData()
    }

    // `parseMockData()`这时我们在开发阶段作为测试时使用的数据 by Kianna 2025/0919
    // 这里的编排使用课程名称-时间-地点-教师名字
    private func parseMockData() -> [CourseInformation] {
        let mockRawData = [
            ("高级软件工程", "星期一 3-4节", "教B-201", "张伟"),
            ("编译原理", "星期二 1-2节", "科A-505", "李静"),
            ("计算机网络", "星期三 5-6节", "教C-110", "王磊"),
            ("操作系统", "星期五 7-8节", "实验楼-302", "赵秀英"),
            ("数据结构", "星期一 7-8节", "教A-101", "陈红"),
            ("大学体育", "星期四 3-4节", "体育馆", "刘强"),
            ("算法设计", "星期二 5-7节", "科A-303", "李静"),
        ]

        var courses: [CourseInformation] = []    // 定义一个空的Course字典
        let calendar = Calendar.current  // 获取与用户当前时区相关的日历
        let today = Date()    // 获取当前日期
        
        // 遍历字典，调用parseTime函数将获取的日程信息的时间解析为Date类型。
        for item in mockRawData {
            if let parsed = ConvertTimeStringToDate(timeString: item.1, relativeTo: today, calendar: calendar) {
                courses.append(CourseInformation(title: item.0, location: item.2, teacher: item.3, startDate: parsed.start, endDate: parsed.end))
            }
            /* 如果检测为nil，忽略。但是为了用户能清楚的明白为什么没有存进去，这里可以开发一个日志信息界面展示
             * 也就是说在导入课程的时候弹出一个日志记录框能让用户清楚的知道哪些日程导入成功，哪些日程导入失败
             */
        }
        return courses
    }

    // 将字符时间转换为Date对象
    private func ConvertTimeStringToDate(timeString: String, relativeTo date: Date, calendar: Calendar) -> (start: Date, end: Date)? {
        let components = timeString.split(separator: " ")
        
        // 如果切片字符串数组不满足两个元素，即周期和课程界数缺少其中一个，则返回nil -2025/09/19
        guard components.count == 2 else { return nil }

        let dayOfWeekStr = String(components[0])  // 周，因为返回到是SubString类型，所以需要再次转换为String
        let slotStr = String(components[1])  // 课程在第几节到第几节，与上同理

        let weekdayMap: [String: Int] = ["星期日": 1, "星期一": 2, "星期二": 3, "星期三": 4, "星期四": 5, "星期五": 6, "星期六": 7]  // 创建一个周的字典
        guard let targetWeekday = weekdayMap[dayOfWeekStr] else { return nil }
        
        // 这里是默认的课程时间，测试中使用，在实际获取日程中应该删除
        let slotMap: [Int: (hour: Int, minute: Int)] = [
            1: (8, 0), 2: (8, 50), 3: (9, 50), 4: (10, 40), 5: (11, 30), 6: (14, 0), 7: (14, 50), 8: (15, 50), 9: (16, 40), 10: (18, 30), 11: (19, 20), 12: (20, 10),
        ]

        let slotComponents = slotStr.dropLast().split(separator: "-")  // 先去掉字符串的末尾元素，然后在按照“-”字符切割
        guard slotComponents.count == 2,
              let startSlot = Int(slotComponents[0]),
              let endSlot = Int(slotComponents[1]) else { return nil }

        guard startSlot <= endSlot else {
            ScheduleV2LogSystem.shared.log("ConvertTimeStringToDate/解析错误：无效的时间范围，起始节数 (\(startSlot)) 大于结束节数 (\(endSlot))", level: .ERROR, module: "struct/GetScheduleFormWebService")
            print("解析错误：无效的时间范围，起始节数 (\(startSlot)) 大于结束节数 (\(endSlot))。")
            return nil
        }

        guard let startTimeInfo = slotMap[startSlot], let endTimeInfo = slotMap[endSlot] else { return nil }

        // 从当前的时区的日期结合当前的时间来判断今天是那一年的那一周的那一天
        var startComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .hour, .minute, .second], from: date)
        startComponents.weekday = targetWeekday    // 获取到哪一年的第几周后，这一事件发生在这一周的星期几
        startComponents.hour = startTimeInfo.hour
        startComponents.minute = startTimeInfo.minute

        var endComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday, .hour, .minute, .second], from: date)
        endComponents.weekday = targetWeekday
        endComponents.hour = endTimeInfo.hour
        endComponents.minute = endTimeInfo.minute

        guard let startDate = calendar.date(from: startComponents),  // 将日期转换为Date格式
              var endDate = calendar.date(from: endComponents) else { return nil }
        
        if let endDateUpdate = calendar.date(byAdding: .minute, value: 45, to: endDate) {
            endDate = endDateUpdate
        }else {
            let alert = NSAlert()
            alert.messageText = "错误"
            alert.informativeText = "在处理课程结束时间时出现错误！"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "确定")
            alert.runModal()
            ScheduleV2LogSystem.shared.log("ConvertTimeStringToDate<日程截止信息时间转换错误>", level: .ERROR, module: "struct/GetScheduleFormWebService")
        }

        return (start: startDate, end: endDate)
    }
}
