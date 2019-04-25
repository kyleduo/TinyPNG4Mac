//
//  MainViewControllerWithXcode.swift
//  TinyPNG4Mac
//
//  Created by Alex_Wu on 4/24/19.
//  Copyright © 2019 kyleduo. All rights reserved.
//

import Cocoa

extension MainViewController{
    func acceptXcode_draggingFileAccept(_ files: Array<URL>) {
        if TPClient.sApiKey == "" {
            showInputPanel()
            return;
        }
        
        let images = collectionXcodeImages(files.first!)
        
        var tasks = [TPTaskInfo]()
        let manager = FileManager.default
        for path in images {
            let fullPath = files.first!.relativePath + "/" + path;
            let file = URL(fileURLWithPath: fullPath);
            let attributes = try? manager.attributesOfItem(atPath: file.path)
            if attributes == nil {
                continue;
            }
            
            let size = attributes![FileAttributeKey.size]!
            if  (size as AnyObject).doubleValue!  < 1024 {
                continue;
            }
            let task = TPTaskInfo(originFile: file, fileName:file.lastPathComponent, originSize: (size as AnyObject).doubleValue!)
            tasks.append(task)
        }
        
        
        TPClient.sharedClient.add(tasks)
        taskTableView.reloadData()
        TPClient.sharedClient.checkExecution()
        
        icon.animator().alphaValue = 0
        desc.animator().alphaValue = 0
        
        lockUI()
        changePanel(false, animated: true)
    }
    
    func acceptXcode_collectionXcodeImages(_ filePath : URL) -> Array<String> {
        var imagePaths = [String]();
        
        do{
            
            let content = try FileManager.default.subpathsOfDirectory(atPath: filePath.relativePath)
            if content.count != 0 {
                for path in content.enumerated(){
                    
                    // ignore .
                    if path.element.hasPrefix("."){
                        continue;
                    }
                    
                    // ignore pods
                    if path.element.hasPrefix("Pods"){
                        continue;
                    }
                    
                    // ignore bundle
                    if path.element.contains("bundle"){
                        continue;
                    }
                    
                    
                    let url = URL(fileURLWithPath: path.element)
                    let fileExtension = url.pathExtension.lowercased()
                    if acceptTypes.contains(fileExtension){
                        imagePaths.append(path.element);
                    }
                }
            }
        }catch{
            print("collection images failed");
        }
        return imagePaths;
    }
    
    func collectionXcodeImages(_ filePath : URL) -> Array<String> {
        var imagePaths = [String]();
        
        do{
            
            let content = try FileManager.default.subpathsOfDirectory(atPath: filePath.relativePath)
            if content.count != 0 {
                for path in content.enumerated(){
                    
                    // ignore .
                    if path.element.hasPrefix("."){
                        continue;
                    }
                    
                    // ignore pods
                    if path.element.hasPrefix("Pods"){
                        continue;
                    }
                    
                    // ignore bundle
                    if path.element.contains("bundle"){
                        continue;
                    }
                    
                    
                    let url = URL(fileURLWithPath: path.element)
                    let fileExtension = url.pathExtension.lowercased()
                    if acceptTypes.contains(fileExtension){
                        imagePaths.append(path.element);
                    }
                }
            }
        }catch{
            print("collection images failed");
        }
        return imagePaths;
    }
}
