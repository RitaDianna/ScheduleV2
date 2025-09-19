//
//  CalendarExporter.swift
//  ScheduleV2
//
//  Created by Kianna on 2025/9/18.
//

import Foundation

/// 定义了日历导出功能的协议 (OCP)。
/// 这允许我们未来可以添加导出到其他格式或应用的功能，
/// 例如导出为 .ics 文件，而无需修改现有的 ViewModel。
protocol CalendarExporterProtocol {
    /// 并发地将一组日程项目添加到目标日历。
    /// - Parameter items: 需要被导出的日程项目。
    /// - Returns: 一个元组，包含成功和失败的计数。
    func export(items: [ScheduleItem]) async -> (successCount: Int, failureCount: Int)
}

