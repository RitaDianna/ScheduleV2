//
//  ScheduleV2Debugl.swift
//  ScheduleV2
//
//  Created by Kianna on 2025/9/20.
//

import Foundation


struct Debug {
    static func log(_ items:Any..., file: String = #file, function: String = #function, line: Int = #line) {
#if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let informationPositioning = "\(fileName):\(line) \(function):"
        let message = items.map { "\($0)" }.joined(separator: " ")
        print(informationPositioning, message)
#endif
        
    }
}
