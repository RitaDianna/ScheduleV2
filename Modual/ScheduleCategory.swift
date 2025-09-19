import SwiftUI
import SwiftData

/// 定义日程的分类，例如 "课程", "工作", "个人" 等
@Model
final class ScheduleCategory {
    @Attribute(.unique) var id: UUID
    var name: String
    
    /// 这里的类型必须是 CodableColor，以便能被 SwiftData 正确存储
    var color: CodableColor
    
    // 【修复】: 修正属性名称
    // SwiftData 关系：一个分类可以有多个日程
    @Relationship(inverse: \ScheduleItem.category)
    var scheduleItems: [ScheduleItem]?

    init(id: UUID = UUID(), name: String, color: CodableColor) {
        self.id = id
        self.name = name
        self.color = color
    }
}

