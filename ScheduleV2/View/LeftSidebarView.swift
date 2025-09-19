
// file ：LeftSidebarView.swift
// 应用主界面左侧边栏视图

import SwiftUI


struct LeftSidebarView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var ScheduleButtonHovered = false
    @State private var DataSourceButtonHovered = false
    @State private var SettingButtonHovered = false

    var body: some View {
        VStack(alignment: .leading ,spacing: 15) {
            Button(action: { appState.selection = .schedule }) {
                Label("日程信息", systemImage: "calendar.badge.clock")
            }
            .buttonStyle(SidebarButtonStyle(selection: $appState.selection, tag: .schedule))
//            .background(ScheduleButtonHovered ? Color.red.opacity(0.5) : Color.clear)
            .scaleEffect(ScheduleButtonHovered ? 1.1 : 1.0)
            .shadow(radius: ScheduleButtonHovered ? 10 : 2)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: ScheduleButtonHovered)
            .onHover { hovering in
                ScheduleButtonHovered = hovering
            }

            Button(action: { appState.selection = .DataSource }) {
                Label("数据源设置", systemImage: "link.badge.plus")
            }
            .buttonStyle(SidebarButtonStyle(selection: $appState.selection, tag: .DataSource))
            .scaleEffect(DataSourceButtonHovered ? 1.1 : 1.0)
            .shadow(radius:DataSourceButtonHovered ? 10 : 2)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: DataSourceButtonHovered)
            .onHover { hovering in
                DataSourceButtonHovered = hovering
            }
            
            Button(action: { appState.selection = .Setting }) {
                Label("设置", systemImage: "list.bullet.circle.fill")
            }
            .buttonStyle(SidebarButtonStyle(selection: $appState.selection, tag: .Setting))
            .scaleEffect(SettingButtonHovered ? 1.1 : 1.0)
            .shadow(radius: SettingButtonHovered ? 10 : 2)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: SettingButtonHovered)
            .onHover { hovering in
                SettingButtonHovered = hovering
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial)  // 普通毛玻璃
        .navigationSplitViewColumnWidth(min: 200, ideal: 240)
        .cornerRadius(12)
    }
}


/// 自定义按钮样式，用于在选中时显示高亮背景
private struct SidebarButtonStyle: ButtonStyle {
    @Binding var selection: SidebarSelection?
    let tag: SidebarSelection

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(selection == tag ? Color.accentColor.opacity(0.3) : Color.clear)
            .cornerRadius(6)
            .contentShape(Rectangle())
    }
}

