import SwiftUI
import SwiftData

// 周视图
struct WeekCalendarView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Query private var items: [ScheduleItem]
    
    @Binding var currentDate: Date
    
    @State private var popoverPosition: CGPoint? = nil
    
    private let timeSlotHeight: CGFloat = 50

    init(currentDate: Binding<Date>) {
        self._currentDate = currentDate
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfWeek(for: currentDate.wrappedValue)
        let endOfWeek = calendar.endOfWeek(for: currentDate.wrappedValue)
        
        _items = Query(filter: #Predicate<ScheduleItem> { item in
            item.startDate >= startOfWeek && item.startDate < endOfWeek
        }, sort: \.startDate)
    }

    var body: some View {
        // 【修复】: 使用 GeometryReader 来获取父视图的尺寸，用于智能定位
        GeometryReader { geometry in
            ZStack {
                // 主要日历内容
                VStack(spacing: 0) {
                    CalendarHeaderView(currentDate: $currentDate, viewMode: .week)
                    Divider()
                    ScrollView {
                        HStack(alignment: .top, spacing: 0) {
                            TimeAxisView(slotHeight: timeSlotHeight)
                            ForEach(currentDate.getWeekDates(), id: \.self) { day in
                                DayColumnView(
                                    date: day,
                                    items: items.filter { Calendar.current.isDate($0.startDate, inSameDayAs: day) },
                                    slotHeight: timeSlotHeight,
                                    onDoubleClick: { position, date in
                                        showPopover(at: position, for: date)
                                    }
                                )
                            }
                        }
                    }
                }
                
                if let position = popoverPosition {
                    // 【修复】: 将父视图的 geometry 传递给 Popover
                    CustomPopoverView(position: position, windowGeometry: geometry) {
                        closePopover()
                    }
                }
            }
        }
    }
    
    private func showPopover(at position: CGPoint, for date: Date) {
        viewModel.newEventStartDate = date
        viewModel.newEventEndDate = date.addingTimeInterval(3600)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.popoverPosition = position
        }
    }

    private func closePopover() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            self.popoverPosition = nil
        }
    }
}


// 周视图的单日列
struct DayColumnView: View {
    let date: Date
    let items: [ScheduleItem]
    let slotHeight: CGFloat
    let onDoubleClick: (CGPoint, Date) -> Void
    
    var body: some View {
        let calendar = Calendar.current
        
        return ZStack(alignment: .top) {
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

// 时间轴视图
struct TimeAxisView: View {
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

// 单个日程的卡片视图
struct ScheduleItemCardView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let item: ScheduleItem
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
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor.opacity(0.8)))
        .foregroundColor(.white)
        .padding(.horizontal, 2)
        .onTapGesture {
            viewModel.itemToEdit = item
        }
    }
}


// 【修复】: 自定义 Popover 的主视图现在包含完整的智能定位逻辑
struct CustomPopoverView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let position: CGPoint
    let windowGeometry: GeometryProxy // 接收父视图的几何信息
    let onClose: () -> Void
    
    // 使用 @State 存储计算出的最终位置和箭头偏移
    @State private var finalPosition: CGPoint = .zero
    @State private var arrowHorizontalOffset: CGFloat = 0.0

    var body: some View {
        Color.black.opacity(0.001)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                onClose()
            }
            .overlay(
                popoverContent
                    .position(finalPosition)
                    .transition(.scale(scale: 0.1, anchor: .top).combined(with: .opacity))
            )
            .onAppear(perform: calculatePosition) // 在视图出现时进行一次计算
    }
    
    private var popoverContent: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.bar)
                .shadow(color: .black.opacity(0.2), radius: 10)

            PopoverArrow()
                .fill(.bar)
                .frame(width: 20, height: 10)
                .offset(y: -10)
                .offset(x: arrowHorizontalOffset) // 应用计算出的箭头偏移

            AddScheduleItemPopoverView(
                startDate: viewModel.newEventStartDate,
                endDate: viewModel.newEventEndDate,
                onClose: onClose
            )
            .padding(.top, 10)
        }
        .frame(width: 340, height: 380)
    }
    
    // 【修复】: 核心的智能定位计算函数
    private func calculatePosition() {
        let popoverSize = CGSize(width: 340, height: 380)
        let arrowHeight: CGFloat = 10
        let spacing: CGFloat = 8
        let windowSize = windowGeometry.size // 父视图 (ZStack) 的尺寸

        // --- 计算 Y 坐标 (Popover的中心点) ---
        let finalY = position.y + (popoverSize.height / 2) + arrowHeight + spacing

        // --- 计算 X 坐标 (Popover的中心点) ---
        let proposedX = position.x
        var finalX = proposedX

        // 检查是否超出左边界
        if (proposedX - popoverSize.width / 2) < 0 {
            finalX = popoverSize.width / 2
        }
        // 检查是否超出右边界
        else if (proposedX + popoverSize.width / 2) > windowSize.width {
            finalX = windowSize.width - popoverSize.width / 2
        }

        self.finalPosition = CGPoint(x: finalX, y: finalY)
        
        // --- 计算箭头的补偿偏移 ---
        // 如果 Popover 主体被平移了，箭头需要反向平移以保持指向原始点击位置
        self.arrowHorizontalOffset = proposedX - finalX
    }
}


// 绘制 Popover 的箭头形状
struct PopoverArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

