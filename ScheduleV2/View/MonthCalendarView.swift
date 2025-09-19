import SwiftUI
import SwiftData

/// 月视图 - 这是一个容器视图，负责响应日期的变化
struct MonthCalendarView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        // 当 appState.currentDate 改变时，SwiftUI 会重新创建 MonthCalendarContentView
        // 这会触发 @Query 使用新的日期范围重新执行
        MonthCalendarContentView(currentDate: appState.currentDate)
    }
}

/// 包含实际月视图 UI 和动态查询的子视图
private struct MonthCalendarContentView: View {
    @Query private var items: [ScheduleItem]
    
    private let currentDate: Date

    init(currentDate: Date) {
        self.currentDate = currentDate
        let calendar = Calendar.current
        // 根据传入的日期，计算出当月的时间区间
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else {
            // 如果计算失败，则查询一个空集
            _items = Query(filter: #Predicate<ScheduleItem> { _ in false }, sort: \.startDate)
            return
        }
        
        // 设置 @Query 的谓词，只获取当前月份内的日程
        _items = Query(filter: #Predicate<ScheduleItem> { item in
            item.startDate >= monthInterval.start && item.startDate < monthInterval.end
        }, sort: \.startDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 【修复】调用无参数的 CalendarHeaderView
            CalendarHeaderView()
            
            VStack(spacing: 0) {
                Divider()
                
                // 使用 GeometryReader 来获取可用空间，以便计算每日格子的高度
                GeometryReader { geometry in
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
                    let days = currentDate.getDaysInMonth()
                    
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(days, id: \.self) { day in
                            MonthDayCell(
                                date: day,
                                items: itemsForDay(day),
                                height: geometry.size.height / CGFloat(days.count / 7),
                                currentMonth: currentDate
                            )
                            .border(Color(.gridColor), width: 0.5)
                        }
                    }
                }
            }
        }
    }
    
    /// 辅助函数，用于过滤出某一天的所有日程
    private func itemsForDay(_ day: Date) -> [ScheduleItem] {
        items.filter { Calendar.current.isDate($0.startDate, inSameDayAs: day) }
    }
}


// MARK: - 子视图

/// 月视图中的单日格子
private struct MonthDayCell: View {
    let date: Date
    let items: [ScheduleItem]
    let height: CGFloat
    let currentMonth: Date
    
    // --- 计算属性 ---
    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var isOfCurrentMonth: Bool { Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month) }
    
    private var itemColor: Color {
        // 如果当天有日程，使用第一个日程的分类颜色，否则用默认颜色
        items.first?.category?.color.swiftUIColor ?? .accentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(date.getDayString())
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isToday ? .white : (isOfCurrentMonth ? .primary : .secondary))
                .padding(4)
                .background(isToday ? Color.accentColor.clipShape(Circle()) : Color.clear.clipShape(Circle()))
            
            // 如果当天有日程，则显示一个摘要
            if !items.isEmpty {
                 Text("\(items.count) 个日程")
                    .font(.caption2)
                    .lineLimit(1)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(itemColor.opacity(0.3).clipShape(Capsule()))
            }
            
            Spacer()
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        // 非当前月份的日期会变暗，以示区分
        .opacity(isOfCurrentMonth ? 1.0 : 0.4)
    }
}

