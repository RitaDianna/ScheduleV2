import SwiftUI

// ... ModernInputField 和 ModernActionButtonStyle 保持不变 ...
struct ModernInputField<Content: View>: View {
    let systemImageName: String
    @ViewBuilder let content: Content
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: systemImageName).font(.title3).foregroundColor(.secondary).frame(width: 25, alignment: .center)
            content
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.underPageBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.gray.opacity(0.1), lineWidth: 1))
    }
}

struct ModernActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline.weight(.semibold)).padding(15).frame(maxWidth: 300)
            .background(LinearGradient(gradient: Gradient(colors: [.accentColor.opacity(0.8), .accentColor]), startPoint: .top, endPoint: .bottom))
            .foregroundColor(.white).clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .shadow(color: .accentColor.opacity(0.3), radius: 8, x: 0, y: 5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0).opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}


// 【重大更新】: 支持悬浮特效的侧边栏按钮样式
struct SidebarButtonStyle: ButtonStyle {
    @Binding var selection: SidebarSelection?
    let tag: SidebarSelection
    
    @State private var isHovering = false
    private var isSelected: Bool { selection == tag }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
        }
        .font(.headline)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            ZStack {
                // 选中时的固定背景
                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor)
                }
                // 悬浮时的动态背景
                else if isHovering {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .transition(.opacity.animation(.easeOut(duration:0.2)))
                }
            }
        )
        .foregroundColor(isSelected ? .white : .primary)
        .contentShape(Rectangle())
        .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
        .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}
