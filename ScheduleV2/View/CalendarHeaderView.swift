import SwiftUI

/// 全新的、可复用的日历页眉，仿系统风格
/// 它现在从环境中获取所有所需的状态
struct CalendarHeaderView: View {
    // 【修复】 1. 从环境中获取 AppState
    @EnvironmentObject private var appState: AppState
    
    // 【修复】 2. title 计算属性现在使用 appState
    private var title: String {
        let formatter = DateFormatter()
        switch appState.calendarViewMode {
        case .week, .month:
            formatter.dateFormat = "MMMM yyyy"
        case .year:
            formatter.dateFormat = "yyyy"
        }
        return formatter.string(from: appState.currentDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack {
                    Button(action: { changeDate(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.plain)
                    
                    Button("Today") {
                        // 【修复】 3. 直接修改 appState 中的 currentDate
                        appState.currentDate = Date()
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: { changeDate(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()

            // 只有周视图和月视图需要显示星期几
            if appState.calendarViewMode == .week || appState.calendarViewMode == .month {
                HStack(spacing: 0) {
                    // 周视图的左侧时间轴占位
                    if appState.calendarViewMode == .week {
                        Spacer().frame(width: 60)
                    }
                    ForEach(appState.currentDate.getWeekDates(), id: \.self) { day in
                        VStack {
                            Text(day.getWeekdayShortString())
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // 只有周视图显示日期数字
                            if appState.calendarViewMode == .week {
                                Text(day.getDayString())
                                    .font(.title3)
                                    .fontWeight(Calendar.current.isDateInToday(day) ? .bold : .regular)
                                    .foregroundStyle(Calendar.current.isDateInToday(day) ? Color.accentColor : .primary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .background(.bar)
    }
    
    /// 根据当前视图模式更改日期
    private func changeDate(by value: Int) {
        let component: Calendar.Component
        switch appState.calendarViewMode {
        case .week:
            component = .weekOfYear
        case .month:
            component = .month
        case .year:
            component = .year
        }
        
        if let newDate = Calendar.current.date(byAdding: component, value: value, to: appState.currentDate) {
            // 【修复】 4. 修改 appState 中的 currentDate
            appState.currentDate = newDate
        }
    }
}

