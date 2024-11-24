//
//  TaskRowView.swift
//  TinePNG4Mac
//
//  Created by kyleduo on 2024/11/23.
//

import SwiftUI

struct TaskRowView: View {
    private let rowHeight: CGFloat = 60
    private let rowPadding: CGFloat = 5
    private let imageSize: CGFloat = 50

    var task: TaskInfo

    var body: some View {
        HStack(spacing: 6) {
            if let uiImage = task.previewImage {
//            if let uiImage = NSImage(contentsOf: task.backupUrl!) {
                Image(nsImage: uiImage) // For macOS
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize, height: imageSize)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Image(systemName: "photo") // Fallback for invalid file
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize, height: imageSize)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
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
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray) // Background color
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// #Preview {
//    TaskRowView()
// }
