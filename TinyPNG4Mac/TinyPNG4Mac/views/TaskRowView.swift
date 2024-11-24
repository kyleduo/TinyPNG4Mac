//
//  TaskRowView.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/23.
//

import SwiftUI

struct TaskRowView: View {
    private let rowHeight: CGFloat = 66
    private let rowPadding: CGFloat = 8
    private let imageSize: CGFloat = 50

    var task: TaskInfo
    var first: Bool
    var last: Bool

    var body: some View {
        HStack(spacing: 6) {
            let uiImage = task.previewImage ?? NSImage(named: "placeholder")!
            
            Image(nsImage: uiImage) // For macOS
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color("taskPreviewStroke"), lineWidth: 1)
                }

            VStack {
                HStack(alignment: .top, spacing: 6) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.originUrl.shortPath())
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)
                            .truncationMode(.head)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(task.originSize?.formatBytes() ?? "NaN")
                            .font(.system(size: 10, weight: .light))
                    }

                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 12, weight: .medium))
                        .frame(width: 20, height: 20)
                }

                Spacer()
                    .frame(minHeight: 0)

                HStack {
                    Spacer()

                    Text(task.statusText())
                        .font(.system(size: 12))
                }
            }
        }
        .padding(rowPadding)
        .frame(height: rowHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("taskRowBackground"))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("taskRowStroke"), lineWidth: 1)
                }
        )
        .shadow(color: Color("taskRowShadow"), radius: 6, x: 0, y: 2)
        .padding(.leading, 4)
        .padding(.trailing, 4)
        .padding(.top, first ? 8 : 4)
        .padding(.bottom, last ? 12 : 6)
    }
}

// #Preview {
//    TaskRowView()
// }
