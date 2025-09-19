//
//  CalendarViewMode.swift
//  ScheduleV2
//
//  Created by Kianna on 2025/9/18.
//

import Foundation

/// 定义日历可以呈现的三种视图模式
enum CalendarViewMode: String, CaseIterable, Identifiable {
    case week = "周"
    case month = "月"
    case year = "年"
    
    var id: String { self.rawValue }
}

