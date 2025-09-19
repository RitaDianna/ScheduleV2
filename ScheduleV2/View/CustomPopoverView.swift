import SwiftUI

/// 重构后的 Popover 视图，直接从环境中获取状态
struct CustomPopoverView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState // 【修复】 1. 从环境中获取 AppState
    
    // --- 内部状态 ---
    @State private var title: String = "新事件"
    @State private var location: String = ""
    @State private var startDate: Date
    @State private var endDate: Date
    
    // 临时的 Popover 尺寸和位置状态
    @State private var finalPosition: CGPoint = .zero
    @State private var arrowHorizontalOffset: CGFloat = 0.0
    
    // 【修复】 2. 创建一个更简单的 init 方法
    init() {
        // 当视图初始化时，从 AppState 中获取初始日期
        // 注意：这部分逻辑在 onAppear 中会再次执行以确保数据最新
        let initialDate = AppState().popoverContext?.date ?? .now
        self._startDate = State(initialValue: initialDate)
        self._endDate = State(initialValue: initialDate.addingTimeInterval(3600))
    }
    
    var body: some View {
        // 使用 GeometryReader 来获取整个窗口的尺寸，用于智能定位
        GeometryReader { windowGeometry in
            // 透明背景，用于捕捉点击事件以关闭 Popover
            Color.black.opacity(0.001)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    appState.popoverContext = nil
                }
                .overlay(
                    popoverContent
                        .position(finalPosition)
                        .transition(.scale(scale: 0.1, anchor: .top).combined(with: .opacity))
                )
                .onAppear {
                    // 当视图出现时，进行定位计算并同步最新日期
                    calculatePosition(windowGeometry: windowGeometry)
                    syncDates()
                }
        }
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
                .offset(x: arrowHorizontalOffset)

            VStack(spacing: 12) {
                HStack {
                    Rectangle().fill(Color.accentColor).frame(width: 4, height: 20)
                    TextField("新事件", text: $title)
                        .textFieldStyle(.plain)
                        .font(.system(size: 18, weight: .medium))
                }
                
                DatePicker("开始", selection: $startDate, displayedComponents: [.hourAndMinute])
                DatePicker("结束", selection: $endDate, displayedComponents: [.hourAndMinute])
                
                Spacer()
                
                Button("添加") {
                    saveItem()
                    appState.popoverContext = nil
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty)
                
            }
            .padding()
        }
        .frame(width: 320, height: 240)
    }
    
    /// 从 AppState 同步最新的日期信息
    private func syncDates() {
        guard let context = appState.popoverContext else { return }
        self.startDate = context.date
        self.endDate = context.date.addingTimeInterval(3600)
    }
    
    /// 保存新项目
    private func saveItem() {
        let newItem = ScheduleItem(title: title, location: location, startDate: startDate, endDate: endDate)
        modelContext.insert(newItem)
        try? modelContext.save()
    }
    
    /// 核心的智能定位计算函数
    private func calculatePosition(windowGeometry: GeometryProxy) {
        guard let context = appState.popoverContext else { return }
        
        let popoverSize = CGSize(width: 320, height: 240)
        let arrowHeight: CGFloat = 10
        let spacing: CGFloat = 8
        let windowSize = windowGeometry.size
        let clickPosition = context.position

        let finalY = clickPosition.y + (popoverSize.height / 2) + arrowHeight + spacing
        
        var finalX = clickPosition.x
        if (clickPosition.x - popoverSize.width / 2) < 0 {
            finalX = popoverSize.width / 2
        } else if (clickPosition.x + popoverSize.width / 2) > windowSize.width {
            finalX = windowSize.width - popoverSize.width / 2
        }

        self.finalPosition = CGPoint(x: finalX, y: finalY)
        self.arrowHorizontalOffset = clickPosition.x - finalX
    }
}


// 绘制 Popover 的箭头形状
private struct PopoverArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

