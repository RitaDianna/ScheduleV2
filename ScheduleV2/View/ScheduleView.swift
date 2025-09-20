import SwiftData
import SwiftUI

/// 日程视图的调度中心
struct ScheduleView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var scheduleViewModel: ScheduleViewModel

    @State private var exportButton = false
    @State private var addEventButton = false

    var body: some View {
        VStack(spacing: 0) {
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
                    Label("导出到日历", systemImage: "tray.and.arrow.up")
                }
                .scaleEffect(exportButton ? 1.05 : 1.0)
                .shadow(radius: exportButton ? 8 : 2)
                .offset(y: exportButton ? -4 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: exportButton)
                .onHover { hovering in
                    exportButton = hovering
                }
                // "添加日程"按钮
                Button(action: {
                    // 【修复】 3. 添加按钮的唯一职责是更新 AppState
                    appState.isShowingAddItemSheet = true
                }) {
                    Label("添加日程", systemImage: "calendar.badge.plus")
                }
                .scaleEffect(addEventButton ? 1.05 : 1.0)
                .shadow(radius: addEventButton ? 8 : 2)
                .offset(y: addEventButton ? -4 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: addEventButton)
                .onHover { hovering in
                    addEventButton = hovering
                }
            }
        }
        // 【修复】 4. 移除了所有 .sheet 修饰符，因为这个职责现在由 ContentView 承担
    }
}
