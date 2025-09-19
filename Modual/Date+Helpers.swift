//
//  Date+Helpers.swift
//  ScheduleV2
//
//  Created by Kianna on 2025/9/18.
//
import Foundation

// MARK: - 日期计算与获取
extension Date {
    
    /// 获取指定日期所在周的所有日期
    func getWeekDates() -> [Date] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else {
            return []
        }
        
        var week: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                week.append(date)
            }
        }
        return week
    }

    /// 获取指定日期所在月份的所有日期，用于生成月视图网格
    func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: self),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) else {
            return []
        }
        
        // 获取月份第一天是星期几 (1 for Sunday, 2 for Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date] = []
        
        // 添加上个月的尾部日期以填满第一周
        let daysToPrepend = (firstWeekday - calendar.firstWeekday + 7) % 7
        if let start = calendar.date(byAdding: .day, value: -daysToPrepend, to: firstDayOfMonth) {
            for i in 0..<daysToPrepend {
                if let date = calendar.date(byAdding: .day, value: i, to: start) {
                    days.append(date)
                }
            }
        }
        
        // 添加本月的所有日期
        let daysInMonth = calendar.range(of: .day, in: .month, for: self)?.count ?? 0
        for i in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: i, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // 添加下个月的头部日期以填满最后一周
        let totalDays = days.count
        let daysToAppend = (7 - (totalDays % 7)) % 7
        if let lastDay = days.last {
            for i in 1...daysToAppend {
                if let date = calendar.date(byAdding: .day, value: i, to: lastDay) {
                    days.append(date)
                }
            }
        }
        
        return days
    }
    
    /// 获取指定年份的所有月份的第一天
    func getMonthsInYear() -> [Date] {
        let calendar = Calendar.current
        guard let yearInterval = calendar.dateInterval(of: .year, for: self) else { return [] }
        
        var months: [Date] = []
        for i in 0..<12 {
            if let month = calendar.date(byAdding: .month, value: i, to: yearInterval.start) {
                months.append(month)
            }
        }
        return months
    }
}


// MARK: - 日期格式化
extension Date {
    
    /// 获取 "d" 格式的日期字符串 (e.g., "5", "15")
    func getDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }
    
    /// 获取 "E" 格式的星期简称 (e.g., "周一", "Mon")
    func getWeekdayShortString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }

    /// 获取 "MMMM" 格式的月份字符串 (e.g., "九月", "September")
    func getMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }
}


// MARK: - Calendar 扩展
extension Calendar {
    /// 获取一周的开始日期
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }

    /// 获取一周的结束日期
    func endOfWeek(for date: Date) -> Date {
        let start = startOfWeek(for: date)
        return self.date(byAdding: .day, value: 6, to: start) ?? date
    }
}

