//
//  NSPasteboard+PasteboardType.swift
//  TinyPNG4Mac
//
//  Created by kyle on 28/03/2018.
//  Copyright © 2018 kyleduo. All rights reserved.
//

import Cocoa

extension NSPasteboard.PasteboardType {
    static let backwardsCompatibleFileURL: NSPasteboard.PasteboardType = {
        if #available(OSX 10.13, *) {
            return NSPasteboard.PasteboardType.fileURL
        } else {
            return NSPasteboard.PasteboardType(kUTTypeFileURL as String)
        }
    } ()
}
