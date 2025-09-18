
import Foundation
import SwiftData

// @Model宏会自动将数据安全地存储在本地的 SQLite 数据库中
@Model
class ScheduleItem {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var location: String
    var teacher: String? // 教师变为可选，因为手动添加的日程可能没有
    var startDate: Date
    var endDate: Date
    var notes: String?

    init(id: UUID = UUID(), title: String, location: String, teacher: String? = nil, startDate: Date, endDate: Date, notes: String? = nil) {
        self.id = id
        self.title = title
        self.location = location
        self.teacher = teacher
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }
}

