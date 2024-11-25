//
//  TaskRowView.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/23.
//

import SwiftUI

struct TaskRowView: View {
    private let rowHeight: CGFloat = 70
    private let rowPadding: CGFloat = 8
    private let imageSize: CGFloat = 54

    @ObservedObject var vm: MainViewModel
    @Binding var task: TaskInfo
    var last: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
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

                            if let finalSize = task.finalSize, task.status == .completed {
                                Image(systemName: "arrow.forward")
                                    .font(.system(size: 10, weight: .light))
                                    .foregroundStyle(Color.white.opacity(0.2))

                                Text(finalSize.formatBytes())
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundStyle(Color("textSecondary"))
                            }
                        }
                    }
                }

                Spacer()
                    .frame(minHeight: 0)

                HStack(spacing: 4) {
                    Spacer()

                    if task.status == .completed {
                        Button {
                            vm.restore(task)
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color("textBody"))
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .help("Restore with origin image")
                    } else if task.status == .failed || task.status == .restored {
                        Button {
                            vm.retry(task)
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color("textBody"))
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .help("Retry task")
                    }

                    Text(task.statusText())
                        .font(.system(size: 12, weight: statusTextWeight(task.status)))
                        .foregroundStyle(statusTextColor(task.status))
                }
            }
        }
        .padding(rowPadding)
        .frame(maxWidth: .infinity, maxHeight: rowHeight, alignment: .leading)
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
