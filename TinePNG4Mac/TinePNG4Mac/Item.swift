//
//  Item.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/16.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
