import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var scheduleViewModel: ScheduleViewModel
    @Query(sort: \ScheduleCategory.name) private var categories: [ScheduleCategory]

    var body: some View {
        NavigationSplitView {  // 创建多分栏视图
            LeftSidebarView()  // 左边侧边栏
        } detail: {
            ZStack {
                switch appState.selection {
                case .schedule:
                    ScheduleView()  // 日程调度中心视图
                case .DataSource:
                    SettingsView()  // 数据源获取模块视图
                case .Setting:
                    CategorySettingsView()  // 分类管理器视图
                case .none:
                    Text("请选择一个项目")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.selection)
        }
        .frame(minWidth: 950, minHeight: 600)
        // 【修复】 修正 alert 的调用语法
        .alert("提示", isPresented: $scheduleViewModel.isShowingAlert) {
            Button("好", role: .cancel) { }
        } message: {
            Text(scheduleViewModel.alertMessage ?? "未知错误")
        }
        // 【修复】 Popover 的调用现在变得非常简洁
        .popover(item: $appState.popoverContext) { _ in
            CustomPopoverView()
        }
        .sheet(isPresented: $appState.isShowingAddItemSheet) {
            AddScheduleItemView(categories: categories, itemToEdit: nil)
        }
        .sheet(item: $appState.itemToEdit) { item in
            AddScheduleItemView(categories: categories, itemToEdit: item)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ScheduleItem.self, ScheduleCategory.self], inMemory: true)
        .environmentObject(AppState())
}
