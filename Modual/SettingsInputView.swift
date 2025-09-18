

import SwiftUI
import SwiftData

// 数据源设置视图
struct SettingsInputView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let modelContext: ModelContext
    
    var body: some View {
        ZStack {
            Color(.windowBackgroundColor).edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(spacing: 30) {
                    VStack {
                        Image(systemName: "link.icloud.fill").font(.system(size: 50)).foregroundColor(.accentColor)
                        Text("数据源设置").font(.largeTitle).fontWeight(.bold)
                        Text("请提供教务系统的链接和必要的登录凭据。").foregroundColor(.secondary)
                    }.padding(.bottom, 20)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("教务系统链接").font(.headline)
                        ModernInputField(systemImageName: "link") {
                            TextField("https://教务系统域名/schedule", text: $viewModel.scheduleURL).textFieldStyle(.plain)
                        }
                        Divider()
                        Toggle(isOn: $viewModel.requiresAuthentication.animation(.easeInOut)) {
                            VStack(alignment: .leading) {
                                Text("需要认证").font(.headline)
                                Text("如果您的教务系统需要登录，请开启此选项。").font(.caption).foregroundColor(.secondary)
                            }
                        }.toggleStyle(.switch)
                        
                        if viewModel.requiresAuthentication {
                            ModernInputField(systemImageName: "person.fill") {
                                TextField("账号/学号", text: $viewModel.username).textFieldStyle(.plain)
                            }.transition(.opacity.combined(with: .move(edge: .top)))
                            ModernInputField(systemImageName: "key.fill") {
                                SecureField("密码", text: $viewModel.password).textFieldStyle(.plain)
                            }.transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(30)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    
                    Button(action: { viewModel.loadAndSaveSchedule(database: modelContext) }) {
                        if viewModel.isLoading { ProgressView().progressViewStyle(.circular).tint(.white) }
                        else { Label("获取并保存", systemImage: "icloud.and.arrow.down") }
                    }
                    .buttonStyle(ModernActionButtonStyle())
                    .disabled(viewModel.isLoading)
                }
                .padding(40)
            }
        }
        .navigationTitle("")
    }
}

