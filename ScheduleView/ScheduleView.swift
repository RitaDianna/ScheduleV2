
import SwiftUI
import SwiftData

// 日程视图的调度中心
struct ScheduleView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var currentDate: Date

    var body: some View {
        VStack(spacing: 0) {
            // 根据选择的模式显示不同的日历视图
            switch viewModel.calendarViewMode {
            case .week:
                WeekCalendarView(currentDate: $currentDate)
            case .month:
                MonthCalendarView(currentDate: $currentDate)
            case .year:
                YearCalendarView(currentDate: $currentDate)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Picker("View Mode", selection: $viewModel.calendarViewMode) {
                    ForEach(CalendarViewMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            ToolbarItemGroup(placement: .automatic) {
                Button(action: {
                    // 【修复】: 直接访问 viewModel 的属性，不使用 "$"
                    viewModel.newEventStartDate = Date()
                    viewModel.newEventEndDate = viewModel.newEventStartDate.addingTimeInterval(3600)
                    
                    // 这个按钮用于打开 Sheet，而不是 Popover
                    // Popover 是通过双击日历触发的
                    viewModel.isShowingAddItemSheet = true
                }) {
                    Label("添加日程", systemImage: "plus")
                }
            }
        }
    }
}

