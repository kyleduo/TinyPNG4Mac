//
//  TaskRowView.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/23.
//

import AppKit
import SwiftUI

struct TaskRowView: View {
    private let rowHeight: CGFloat = 70
    private let rowPadding: CGFloat = 8
    private let imageSize: CGFloat = 54

    @ObservedObject var vm: MainViewModel
    @Binding var task: TaskInfo
    var last: Bool

    @State var titleUnderline: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 6) {
                let uiImage = task.previewImage ?? NSImage(named: "placeholder")!

                Image(nsImage: uiImage)
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
                                .underline(titleUnderline)
                                .lineLimit(1)
                                .truncationMode(.head)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    NSWorkspace.shared.open(task.originUrl)
                                }
                                .onHover { hover in
                                    titleUnderline = hover
                                }

                            HStack(alignment: .center, spacing: 4) {
                                Text(task.originSize?.formatBytes() ?? "NaN")
                                    .font(.system(size: 10, weight: .light))
                                    .foregroundStyle(Color("textCaption"))

                                if let finalSize = task.finalSize, task.status == .completed {
                                    Image(systemName: "arrow.forward")
                                        .font(.system(size: 10, weight: .light))
                                        .foregroundStyle(Color.white.opacity(0.3))

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

                        Text(task.statusText())
                            .font(.system(size: 12, weight: statusTextWeight(task.status)))
                            .foregroundStyle(statusTextColor(task.status))
                    }
                }
            }
            .padding(rowPadding)
            .frame(height: rowHeight)
            .frame(maxWidth: .infinity, alignment: .leading)

            if task.status == .failed {
                HorizontalDivider()
                    .padding(vertical: 0, horizontal: rowPadding)
                    .frame(height: 2)

                HStack {
                    let errorText = "Error: \(task.error?.displayText() ?? "unknown")"
                    Text(errorText)
                        .font(.system(size: 12))
                        .foregroundStyle(Color("textSecondary"))
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        vm.retry(task)
                    } label: {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color("textSecondary"))
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Retry the task")
                }
                .padding(.leading, rowPadding)
                .padding(.trailing, rowPadding)
                .padding(.bottom, rowPadding)
                .padding(.top, 8)
            }
        }
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
        .contextMenu {
            Button {
                NSWorkspace.shared.open(task.originUrl)
            } label: {
                Text("Open Origin Image")
            }

            Button {
                NSWorkspace.shared.open(task.originUrl.deletingLastPathComponent())
            } label: {
                Text("Open Origin Folder")
            }

            Divider()

            if task.status == .restored {
                Button {
                    vm.retry(task)
                } label: {
                    Text("Compress again")
                }
            }

            Button {
                NSWorkspace.shared.open(task.outputUrl!)
            } label: {
                Text("Open Compressed Image")
            }
            .disabled(task.status != .completed)

            Button {
                NSWorkspace.shared.open(task.outputUrl!.deletingLastPathComponent())
            } label: {
                Text("Open Output Folder")
            }

            Divider()

            Button {
                vm.restore(task)
            } label: {
                Text("Restore Origin Image")
            }
            .disabled(task.status != .completed)
        }
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

extension TaskInfo {
    fileprivate func statusText() -> String {
        if (status == .uploading || status == .downloading) && progress > 0 {
            status.displayText() + " (\(formatedProgress()))"
        } else {
            status.displayText()
        }
    }

    private func formatedProgress() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: progress)) ?? "\(progress)%"
    }
}

extension TaskStatus {
    fileprivate func displayText() -> String {
        switch self {
        case .created:
            String(localized: "Pending")
        case .cancelled:
            String(localized: "Cancelled")
        case .failed:
            String(localized: "Failed")
        case .completed:
            String(localized: "Completed")
        case .uploading:
            String(localized: "Uploading")
        case .processing:
            String(localized: "Processing")
        case .downloading:
            String(localized: "Downloading")
        case .restored:
            String(localized: "Restored")
        }
    }
}

// #Preview {
//    TaskRowView()
// }
