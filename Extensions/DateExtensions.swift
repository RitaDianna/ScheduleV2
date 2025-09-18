import Foundation

// Date 扩展，用于处理日历逻辑
extension Date {
    // MARK: - Week Calculation
    func getWeekDates() -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfWeek(for: self)
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                dates.append(date)
            }
        }
        return dates
    }
    
    static func getWeekdays(for date: Date) -> [Date] {
        return date.getWeekDates()
    }

    // MARK: - Month Calculation
    func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: self),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self))
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let emptyPrefixCells = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date] = []
        if let startDate = calendar.date(byAdding: .day, value: -emptyPrefixCells, to: firstDayOfMonth) {
            for i in 0..<(emptyPrefixCells + monthInterval.durationInDays) {
                if let day = calendar.date(byAdding: .day, value: i, to: startDate) {
                    days.append(day)
                }
            }
        }
        return days
    }
    
    // MARK: - Year Calculation
    func getMonthsInYear() -> [Date] {
        let calendar = Calendar.current
        var months: [Date] = []
        guard let yearInterval = calendar.dateInterval(of: .year, for: self) else { return [] }
        
        for i in 0..<12 {
            if let month = calendar.date(byAdding: .month, value: i, to: yearInterval.start) {
                months.append(month)
            }
        }
        return months
    }

    // MARK: - String Formatting
    func getWeekdayShortString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // 例如 "Mon", "Tue"
        return formatter.string(from: self)
    }
    
    func getDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // 例如 "1", "15"
        return formatter.string(from: self)
    }
    
    func getMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }
}

extension Calendar {
    // 获取给定日期所在周的开始
    func startOfWeek(for date: Date) -> Date {
        let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        guard let startOfWeek = self.date(from: components) else {
            fatalError("Could not calculate start of the week")
        }
        return startOfWeek
    }
    
    // 获取给定日期所在周的结束
    func endOfWeek(for date: Date) -> Date {
        let start = startOfWeek(for: date)
        guard let endOfWeek = self.date(byAdding: .day, value: 7, to: start),
              let endMoment = self.date(byAdding: .second, value: -1, to: endOfWeek) else {
            fatalError("Could not calculate end of the week")
        }
        return endMoment
    }
}

extension DateInterval {
    var durationInDays: Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
}
