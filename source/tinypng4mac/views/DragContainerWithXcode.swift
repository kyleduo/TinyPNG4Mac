//
//  DragContainerWithXcode.swift
//  TinyPNG4Mac
//
//  Created by Alex_Wu on 4/24/19.
//  Copyright © 2019 kyleduo. All rights reserved.
//

import Cocoa

public let xcode_acceptTypes = ["xcodeproj","xcworkspace"]

extension DragContainer{
    func acceptXcode_performDragOperation(_ sender: NSDraggingInfo) -> Bool{
        var files = Array<URL>()
        if let board = sender.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray {
            for path in board {
                do{
                    let content = try FileManager.default.contentsOfDirectory(atPath: path as! String)
                    for fileName in content.enumerated() {
                        let url = URL(fileURLWithPath: fileName.element)
                        let fileExtension = url.pathExtension.lowercased()
                        if xcode_acceptTypes.contains(fileExtension){
                            files.append(URL(fileURLWithPath: path as! String))
                            break; // only get one
                        }
                    }
                }catch{
                    print("drag failed, path extension error");
                }
            }
        }
        
        if self.delegate != nil && files.count != 0 {
            self.delegate?.draggingFileAccept(files);
        }
        
        return true
    }
    
    func acceptXcode_checkExtension(_ draggingInfo: NSDraggingInfo) -> Bool {
        if let board = draggingInfo.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray {
            for path in board {
                do{
                    let content = try FileManager.default.contentsOfDirectory(atPath: path as! String)
                    for fileName in content.enumerated() {
                        let url = URL(fileURLWithPath: fileName.element)
                        let fileExtension = url.pathExtension.lowercased()
                        if xcode_acceptTypes.contains(fileExtension){
                            return true;
                        }
                    }
                }catch{
                    return false;
                }
            }
        }
        return false
    }
}
