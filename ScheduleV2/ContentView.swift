import SwiftUI

// 应用的根视图，负责搭建整体布局
struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            ZStack {
                switch viewModel.selection {
                case .schedule:
                    ScheduleView(currentDate: $viewModel.currentDate)
                case .settings:
                    SettingsInputView(modelContext: modelContext)
                case .none:
                    Text("请选择一个项目").font(.title).foregroundColor(.secondary)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.selection)
            .animation(.easeInOut(duration: 0.3), value: viewModel.calendarViewMode)
        }
        .environmentObject(viewModel)
        .frame(minWidth: 950, minHeight: 600)
        .alert("提示", isPresented: $viewModel.isShowingAlert) {
            Button("好", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
        // 【修复】: 更新 .popover 的调用方式以匹配新的 init 方法
        .popover(isPresented: $viewModel.isShowingAddPopover, arrowEdge: .bottom) {
            AddScheduleItemPopoverView(
                startDate: viewModel.newEventStartDate,
                endDate: viewModel.newEventEndDate,
                onClose: {
                    viewModel.isShowingAddPopover = false
                }
            )
        }
        .sheet(item: $viewModel.itemToEdit) { item in
            AddScheduleItemView(item: item)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ScheduleItem.self, inMemory: true)
}
