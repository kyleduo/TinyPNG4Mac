//
//  UIUtils.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/23.
//

import SwiftUI

struct UIUtils {
    

    static func colorFromHex(_ hex: String) -> Color {
        var cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Remove '#' if it's present
        if cleanedHex.hasPrefix("#") {
            cleanedHex.removeFirst()
        }
        
        // Ensure the hex string is valid
        guard cleanedHex.count == 6 || cleanedHex.count == 8 else {
            return Color.gray // Return gray color for invalid hex
        }
        
        // Add alpha value if not present (defaults to 1.0)
        if cleanedHex.count == 6 {
            cleanedHex += "FF" // Default alpha to full opacity
        }
        
        // Extract RGB and alpha components from hex string
        let scanner = Scanner(string: cleanedHex)
        var hexInt: UInt64 = 0
        if scanner.scanHexInt64(&hexInt) {
            let red = Double((hexInt >> 24) & 0xFF) / 255.0
            let green = Double((hexInt >> 16) & 0xFF) / 255.0
            let blue = Double((hexInt >> 8) & 0xFF) / 255.0
            let alpha = Double(hexInt & 0xFF) / 255.0
            return Color(red: red, green: green, blue: blue, opacity: alpha)
        }
        
        return Color.gray // Return gray color for invalid hex
    }
}


extension Color {
    init(hex: String) {
        self = UIUtils.colorFromHex(hex)
    }
}
