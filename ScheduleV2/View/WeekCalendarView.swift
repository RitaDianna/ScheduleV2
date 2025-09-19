import SwiftUI
import SwiftData

/// 周视图
struct WeekCalendarView: View {
    @EnvironmentObject private var appState: AppState
    
    // 使用 @Query 获取当前周的日程
    @Query private var items: [ScheduleItem]
    private let timeSlotHeight: CGFloat = 50

    // 初始化方法，根据当前日期设置查询谓词
    init() {
        let currentDate = AppState().currentDate // 使用一个临时实例来获取初始值
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfWeek(for: currentDate)
        let endOfWeek = calendar.endOfWeek(for: currentDate)
        
        _items = Query(filter: #Predicate<ScheduleItem> { item in
            item.startDate >= startOfWeek && item.startDate < endOfWeek
        }, sort: \.startDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            CalendarHeaderView()
            Divider()
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    TimeAxisView(slotHeight: timeSlotHeight)
                    
                    // 遍历当前周的每一天
                    ForEach(appState.currentDate.getWeekDates(), id: \.self) { day in
                        DayColumnView(
                            date: day,
                            items: items.filter { Calendar.current.isDate($0.startDate, inSameDayAs: day) },
                            slotHeight: timeSlotHeight,
                            onDoubleClick: { position, date in
                                // 当双击时，更新 AppState 来触发 Popover
                                // 【修复】 1. 使用 AppState.PopoverContext
                                appState.popoverContext = AppState.PopoverContext(position: position, date: date)
                            }
                        )
                    }
                }
            }
        }
        // 【修复】 2. 移除了 .popover 修饰符，该职责已移交至 ContentView
    }
}


// MARK: - 子视图

/// 周视图的单日列
private struct DayColumnView: View {
    let date: Date
    let items: [ScheduleItem]
    let slotHeight: CGFloat
    let onDoubleClick: (CGPoint, Date) -> Void
    
    var body: some View {
        let calendar = Calendar.current
        
        return ZStack(alignment: .top) {
            // 背景时间格，用于捕捉双击事件
            VStack(spacing: 0) {
                ForEach(0..<24, id: \.self) { hour in
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture(count: 2) {
                                let frame = geo.frame(in: .global)
                                let position = CGPoint(x: frame.midX, y: frame.midY)
                                
                                let components = calendar.dateComponents([.year, .month, .day], from: date)
                                var newComponents = DateComponents()
                                newComponents.year = components.year
                                newComponents.month = components.month
                                newComponents.day = components.day
                                newComponents.hour = hour
                                let tappedDate = calendar.date(from: newComponents) ?? date
                                
                                onDoubleClick(position, tappedDate)
                            }
                    }
                    .frame(height: slotHeight - 1)
                    Divider()
                }
            }
            
            // 渲染日程卡片
            ForEach(items) { item in
                let startHour = calendar.component(.hour, from: item.startDate)
                let startMinute = calendar.component(.minute, from: item.startDate)
                let durationInMinutes = item.endDate.timeIntervalSince(item.startDate) / 60
                
                let yOffset = (CGFloat(startHour) + CGFloat(startMinute) / 60.0) * slotHeight
                let height = (durationInMinutes / 60.0) * slotHeight
                
                ScheduleItemCardView(item: item)
                    .frame(height: max(20, height - 2))
                    .offset(y: yOffset + 1)
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(Rectangle().frame(width: 1).foregroundColor(Color(.gridColor)), alignment: .trailing)
    }
}

/// 左侧的时间轴
private struct TimeAxisView: View {
    let slotHeight: CGFloat
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { hour in
                Text(String(format: "%02d:00", hour))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: slotHeight, alignment: .top)
            }
        }
        .frame(width: 60)
        .overlay(Rectangle().frame(width: 1).foregroundColor(Color(.gridColor)), alignment: .trailing)
    }
}

/// 单个日程的卡片视图
private struct ScheduleItemCardView: View {
    @EnvironmentObject private var appState: AppState
    let item: ScheduleItem
    
    // 计算属性，用于安全地获取颜色
    private var itemColor: Color {
        item.category?.color.swiftUIColor ?? .accentColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title).font(.headline).fontWeight(.bold)
            Text(item.location).font(.subheadline)
            if let teacher = item.teacher, !teacher.isEmpty {
                Text(teacher).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 8).fill(itemColor.opacity(0.8)))
        .foregroundColor(.white)
        .padding(.horizontal, 2)
        .onTapGesture {
            // 单击时，触发编辑
            appState.itemToEdit = item
        }
    }
}

