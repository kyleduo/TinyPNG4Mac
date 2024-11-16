//
//  DropFileView.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/16.
//

import SwiftUI
import UniformTypeIdentifiers

struct DropFileView: View {
    @State private var droppedFilePath: String = "Drop a file here!"

    var body: some View {
        VStack {
            Text(droppedFilePath)
                .multilineTextAlignment(.center)
                .padding()

            Rectangle()
                .fill(Color.white.opacity(0.4))
                .overlay(
                    Text("Drop File Here")
                        .font(.headline)
                        .foregroundColor(.blue)
                )
                .cornerRadius(10)
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    handleDrop(providers: providers)
                }
        }
        .padding()
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var ret: Bool = false
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                let _ = provider.loadObject(ofClass: URL.self) { item, _ in
                    if let url = item {
                        print(url)
                        DispatchQueue.main.async {
                            droppedFilePath = url.path
                        }
                    }
                }
                ret = true
            }
        }
        return ret
    }
}
