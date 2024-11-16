//
//  DropFileView.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/16.
//

import SwiftUI
import UniformTypeIdentifiers

struct DropFileView: View {
    @Binding var dropResult: [URL]
    
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .cornerRadius(10)
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                handleDrop(providers: providers)
            }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var ret: Bool = false
        var urls: [URL] = Array()
        let group = DispatchGroup() // To wait for all asynchronous calls
        
        for provider in providers {
            if !provider.canLoadObject(ofClass: URL.self) {
                continue
            }
            group.enter()
            let _ = provider.loadObject(ofClass: URL.self) { item, _ in
                if let url = item {
                    urls.append(url)
                }
                group.leave()
            }
            ret = true
        }
        
        group.notify(queue: .main) {
            let imageUrls = DocumentUtils.findImageFiles(urls: urls)
            dropResult = imageUrls
        }
        
        return ret
    }
}
