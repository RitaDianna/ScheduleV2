import SwiftUI

/// AppState 管理所有与UI导航和瞬时状态相关的属性
class AppState: ObservableObject {
    
    /// 定义了 Popover 显示时所需的所有上下文信息
    /// 'Identifiable' 协议是让 .popover(item:) 可以工作的关键
    struct PopoverContext: Identifiable {
        let id = UUID()
        let position: CGPoint
        let date: Date
    }
    
    @Published var selection: SidebarSelection? = .schedule
    @Published var currentDate: Date = .now
    @Published var calendarViewMode: CalendarViewMode = .week
    
    // Popover 状态
    @Published var popoverContext: PopoverContext?
    
    // Sheet 状态
    @Published var isShowingAddItemSheet = false
    @Published var itemToEdit: ScheduleItem?
}

