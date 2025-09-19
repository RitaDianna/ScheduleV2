import SwiftUI

/// 一个可被编码和解码的颜色结构，用于在 SwiftData 中持久化存储颜色信息。
struct CodableColor: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    /// 从一个 SwiftUI 的 Color 初始化
    init(color: Color) {
        // 在 macOS 上，Color 内部包装的是 NSColor
        let nsColor = NSColor(color)
        
        // 【修复】1. 先将传入的颜色转换为一个标准的 sRGB 色彩空间。
        // 这是处理来自 Asset Catalog 的动态颜色（如 accentColor）的关键。
        guard let srgbColor = nsColor.usingColorSpace(.sRGB) else {
            // 如果转换失败（极少发生），则使用一个安全的回退值。
            self.red = 0; self.green = 0; self.blue = 0; self.alpha = 1
            return
        }
        
        // 【修复】2. 现在，从这个转换后的、色彩空间明确的颜色中安全地获取组件。
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        srgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
    
    /// 将存储的 RGBA 值转换回 SwiftUI 的 Color
    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

