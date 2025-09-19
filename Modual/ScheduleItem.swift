import SwiftUI
import SwiftData

/// 核心数据模型：代表一个日程项目
@Model
final class ScheduleItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var location: String
    var teacher: String?
    var startDate: Date
    var endDate: Date
    var notes: String?

    // SwiftData 关系：一个日程项目属于一个分类
    var category: ScheduleCategory?

    init(id: UUID = UUID(), title: String, location: String, teacher: String? = nil, startDate: Date, endDate: Date, notes: String? = nil, category: ScheduleCategory? = nil) {
        self.id = id
        self.title = title
        self.location = location
        self.teacher = teacher
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.category = category
    }

    /// 【修复】: 添加这个计算属性来安全地获取用于视图的颜色
    /// 如果日程没有分类，则返回一个默认颜色
    @Transient // 这个属性不需要存储在数据库中
    var viewColor: Color {
        // 1. 安全地访问 category 上的 color 属性 (类型是 CodableColor?)
        // 2. 将 CodableColor? 转换为 SwiftUI.Color?
        // 3. 如果结果是 nil, 提供一个默认的 SwiftUI.Color
        category?.color.swiftUIColor ?? .accentColor
    }
}

