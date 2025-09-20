//
//  ScheduleV2Error.swift
//  ScheduleV2
//
//  Created by Kianna on 2025/9/20.
//

import Foundation

enum ScheduleV2Error: Error {
    
    case permissionDenied // 没有权限
    case restricted // 受到限制
    case systemVersionIsLow // 版本过低
    
    
}
