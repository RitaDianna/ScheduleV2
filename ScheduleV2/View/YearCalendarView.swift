import SwiftUI
import SwiftData

/// 年视图
struct YearCalendarView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            // 【修复】调用无参数的 CalendarHeaderView
            CalendarHeaderView()
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                    // 直接从 appState 获取当前年份的月份列表
                    ForEach(appState.currentDate.getMonthsInYear(), id: \.self) { month in
                        YearMonthView(month: month)
                    }
                }
                .padding()
            }
        }
    }
}


// MARK: - 子视图

/// 年视图中的单月视图
private struct YearMonthView: View {
    let month: Date
    private let days: [Date]
    private let calendar = Calendar.current
    
    init(month: Date) {
        self.month = month
        self.days = month.getDaysInMonth()
    }
    
    var body: some View {
        VStack {
            Text(month.getMonthString())
                .font(.headline)
                .padding(.bottom, 5)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days, id: \.self) { day in
                    Text(day.getDayString())
                        .font(.caption)
                        .foregroundColor(foregroundColor(for: day))
                        .frame(width: 20, height: 20)
                        .background(backgroundColor(for: day).clipShape(Circle()))
                }
            }
        }
    }
    
    /// 根据日期计算前景（文字）颜色
    private func foregroundColor(for day: Date) -> Color {
        if calendar.isDateInToday(day) { return .white }
        // 如果日期不属于当前月份，则显示为灰色
        if !calendar.isDate(day, equalTo: month, toGranularity: .month) { return .secondary }
        return .primary
    }
    
    /// 根据日期计算背景颜色
    private func backgroundColor(for day: Date) -> Color {
        calendar.isDateInToday(day) ? Color.accentColor : Color.clear
    }
}

