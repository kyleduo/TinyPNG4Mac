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

    @Binding var task: TaskInfo
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
                            .foregroundStyle(Color("textBody"))
                            .lineLimit(1)
                            .truncationMode(.head)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(alignment: .center, spacing: 4) {
                            Text(task.originSize?.formatBytes() ?? "NaN")
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(Color("textCaption"))

                            if let finalSize = task.finalSize {
                                Image(systemName: "arrow.forward")
                                    .font(.system(size: 10, weight: .light))
                                    .foregroundStyle(Color.white.opacity(0.2))

                                Text(finalSize.formatBytes())
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundStyle(Color("textSecondary"))
                            }
                        }
                    }

                    /*
                     
                     1. display action button after task complete / error
                     2. when error, display retry button
                     3. when complete, display recover button
                     
                    Menu {
                        Button("Cancel") {
                            print("Option 3 selected")
                        }
                        Divider()
                        Button("Recover") {
                            print("Option 3 selected")
                        }
                        .disabled(task.status != .completed)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color("textBody"))
                            .frame(width: 20, height: 20)
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    .menuIndicator(.hidden)
                    .frame(width: 20, height: 20)
                     */
                }

                Spacer()
                    .frame(minHeight: 0)

                HStack {
                    Spacer()

                    Text(task.statusText())
                        .font(.system(size: 12, weight: statusTextWeight(task.status)))
                        .foregroundStyle(statusTextColor(task.status))
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
        .shadow(color: Color("taskRowShadow"), radius: 4, x: 0, y: 2)
        .padding(.leading, 4)
        .padding(.trailing, 4)
        .padding(.top, 4)
        .padding(.bottom, last ? 12 : 6)
    }

    func statusTextColor(_ status: TaskStatus) -> Color {
        switch status {
        case .failed:
            Color("textRed")
        case .cancelled:
            Color("textCaption")
        case .completed:
            Color("textGreen")
        default:
            Color("textSecondary")
        }
    }

    func statusTextWeight(_ status: TaskStatus) -> Font.Weight {
        switch status {
        case .completed:
            .medium
        default:
            .regular
        }
    }
}

// #Preview {
//    TaskRowView()
// }
