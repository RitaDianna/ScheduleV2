import SwiftUI
import SwiftData

/// 日程视图的调度中心
struct ScheduleView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var scheduleViewModel: ScheduleViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 【修复】 1. switch 语句现在直接使用 appState 中的 calendarViewMode
            switch appState.calendarViewMode {
            case .week:
                WeekCalendarView()
            case .month:
                MonthCalendarView()
            case .year:
                YearCalendarView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                // 【修复】 2. Picker 也直接绑定到 appState.calendarViewMode
                Picker("View Mode", selection: $appState.calendarViewMode) {
                    ForEach(CalendarViewMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            ToolbarItemGroup {
                // "导出到日历"按钮
                Button(action: {
                    Task {
                        await scheduleViewModel.exportToSystemCalendar()
                    }
                }) {
                    Label("导出到日历", systemImage: "arrow.up.doc")
                }
                
                // "添加日程"按钮
                Button(action: {
                    // 【修复】 3. 添加按钮的唯一职责是更新 AppState
                    appState.isShowingAddItemSheet = true
                }) {
                    Label("添加日程", systemImage: "plus")
                }
            }
        }
        // 【修复】 4. 移除了所有 .sheet 修饰符，因为这个职责现在由 ContentView 承担
    }
}

