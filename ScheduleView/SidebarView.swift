import SwiftUI

enum SidebarSelection: Hashable {
    case schedule
    case settings
}

struct SidebarView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: { selectionChanged(to: .schedule) }) {
                Label("日程信息", systemImage: "calendar")
            }
            .buttonStyle(SidebarButtonStyle(selection: $viewModel.selection, tag: .schedule))

            Button(action: { selectionChanged(to: .settings) }) {
                Label("数据源设置", systemImage: "link.badge.plus")
            }
            .buttonStyle(SidebarButtonStyle(selection: $viewModel.selection, tag: .settings))
            
            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .navigationSplitViewColumnWidth(min: 200, ideal: 240)
    }
    
    private func selectionChanged(to newSelection: SidebarSelection) {
        withAnimation(.easeInOut) {
            viewModel.selection = newSelection
        }
    }
}

