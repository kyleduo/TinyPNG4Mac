//
//  Extensions.swift
//  TinePNG4Mac
//
//  Created by kyleduo on 2024/11/23.
//

import Foundation

extension UInt64 {
    func formatBytes() -> String {
        let units = ["B", "KB", "MB", "GB"]
        var size = Double(self)
        var unitIndex = 0

        // Keep dividing the size by 1024 to find the most suitable unit
        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }
        
        size = (size * 10).rounded() / 10

        // Return the formatted string with one decimal point
        return String(format: "%.1f %@", size, units[unitIndex])
    }
}
