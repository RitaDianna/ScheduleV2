
// file : SettingsView.swift
// 数据源获取模块视图。 Creat by Kianna on 2025/09/19.

import SwiftUI
import SwiftData


struct SettingsView: View {
    @StateObject private var settingsViewModel = DataSourceSettingsViewModel()
    @EnvironmentObject private var scheduleViewModel: ScheduleViewModel
    
    var body: some View {
        ZStack {
            // 使用一个精细的背景材质，提供毛玻璃效果。
            Color.clear.background(.ultraThickMaterial)
            
            ScrollView {
                // 使用 VStack 限制内容区域的最大宽度，以优化宽屏显示效果。
                VStack(spacing: 40) {
                    // 顶部标题区域
                    VStack(spacing: 8) {
                        Image(systemName: "link.icloud.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [Color.accentColor, Color.accentColor.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        Text("数据源设置")
                            .font(.largeTitle.weight(.bold))
                        Text("请提供教务系统的链接和必要的登录凭据。")
                            .font(.headline.weight(.regular))
                            .foregroundColor(.secondary)
                    }
                    
                    // 输入表单区域
                    VStack(alignment: .leading, spacing: 25) {
                        Text("教务系统链接")
                            .font(.headline)
                        
                        ModernInputField(
                            systemImageName: "link",
                            placeholder: "https://教务系统域名/schedule",
                            text: $settingsViewModel.scheduleURL
                        )
                        
                        Divider()
                        
                        Toggle(isOn: $settingsViewModel.requiresAuthentication.animation(.easeInOut)) {
                            VStack(alignment: .leading) {
                                Text("需要认证")
                                    .font(.headline)
                                Text("如果您的教务系统需要登录，请开启此选项。")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(.switch)
                        
                        if settingsViewModel.requiresAuthentication {
                            ModernInputField(
                                systemImageName: "person.fill",
                                placeholder: "账号/学号",
                                text: $settingsViewModel.username
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            
                            ModernInputField(
                                systemImageName: "key.fill",
                                isSecure: true,
                                placeholder: "密码",
                                text: $settingsViewModel.password
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(30)
                    .background(.regularMaterial) // 使用更明显的毛玻璃材质
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.black.opacity(0.1), lineWidth: 1)
                    )
                    
                    // 操作按钮
                    Button(action: {
                        Task {
                            await scheduleViewModel.loadAndSaveSchedule(from: settingsViewModel)
                        }
                    }) {
                        if settingsViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Label("获取并保存", systemImage: "icloud.and.arrow.down")
                        }
                    }
                    .buttonStyle(ModernActionButtonStyle()) // 应用自定义的按钮样式
                    .disabled(settingsViewModel.isLoading)
                }
                .padding(40)
                .frame(maxWidth: 600) // 限制最大宽度
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("")
    }
}


/// 现代风格的输入框，包含图标和自定义样式。
private struct ModernInputField: View {
    let systemImageName: String
    var isSecure: Bool = false
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
            }
        }
        .padding(12)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(10)
    }
}


/// 现代风格的操作按钮样式，具有渐变背景和阴影。
private struct ModernActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .shadow(color: .accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

