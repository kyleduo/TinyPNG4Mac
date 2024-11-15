//
//  FileInfo.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2019/9/26.
//  Copyright © 2019 kyleduo. All rights reserved.
//

import Foundation

class FileInfo {
    var filePath: URL
    var relativePath: String
    
    init(_ filePath: URL, relativePath: String) {
        self.filePath = filePath
        self.relativePath = relativePath
    }
}
