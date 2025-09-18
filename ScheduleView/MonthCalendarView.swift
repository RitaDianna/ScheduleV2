import SwiftUI
import SwiftData

// 【重大更新】: 全功能的月视图
struct MonthCalendarView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var currentDate: Date
    
    // 【性能优化】: 查询当前月份的所有日程
    @Query private var items: [ScheduleItem]
    
    init(currentDate: Binding<Date>) {
        self._currentDate = currentDate
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate.wrappedValue) else {
            // 如果无法获取月份区间，查询一个空数组
            _items = Query(filter: #Predicate<ScheduleItem> { _ in false }, sort: \.startDate)
            return
        }
        
        _items = Query(filter: #Predicate<ScheduleItem> { item in
            item.startDate >= monthInterval.start && item.startDate < monthInterval.end
        }, sort: \.startDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            CalendarHeaderView(currentDate: $currentDate, viewMode: .month)
            
            VStack(spacing: 0) {
                // 星期标题
                HStack(spacing: 0) {
                    ForEach(Date.getWeekdays(for: currentDate), id: \.self) { day in
                        Text(day.getWeekdayShortString())
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
                
                Divider()
                
                // 日期网格
                GeometryReader { geometry in
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
                    let days = currentDate.getDaysInMonth()
                    
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(days, id: \.self) { day in
                            MonthDayCell(date: day, items: itemsForDay(day), height: geometry.size.height / CGFloat(days.count / 7))
                                .border(Color(.gridColor), width: 0.5)
                        }
                    }
                }
            }
        }
    }
    
    private func itemsForDay(_ day: Date) -> [ScheduleItem] {
        items.filter { Calendar.current.isDate($0.startDate, inSameDayAs: day) }
    }
}

// 月视图中的单日格子
struct MonthDayCell: View {
    let date: Date
    let items: [ScheduleItem]
    let height: CGFloat
    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var isCurrentMonth: Bool { Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(date.getDayString())
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isToday ? .white : (isCurrentMonth ? .primary : .secondary))
                .padding(4)
                .background(isToday ? Color.accentColor.clipShape(Circle()) : Color.clear.clipShape(Circle()))
            
            ForEach(items.prefix(3)) { item in // 最多显示3个项目
                Text(item.title)
                    .font(.caption2)
                    .lineLimit(1)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.3).clipShape(Capsule()))
            }
            
            Spacer()
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
    }
}

