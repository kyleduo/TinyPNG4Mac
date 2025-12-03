//
//  TaskRowView.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/23.
//

import AppKit
import SwiftUI

struct TaskRowView: View {
    private let rowPadding: CGFloat = 8
    private let imageSize: CGFloat = 60

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
                    VStack(alignment: .leading, spacing: 2) {
                        // File path + Menu
                        HStack {
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

                            Menu {
                                Button {
                                    NSWorkspace.shared.open(task.originUrl)
                                } label: {
                                    Text("Open Origin Image")
                                }

                                Button {
                                    NSWorkspace.shared.open(task.originUrl.deletingLastPathComponent())
                                } label: {
                                    Text("Reveal Origin Image in Finder")
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
                                    Text("Reveal Compressed Image in Finder")
                                }

                                Divider()

                                Button {
                                    vm.restore(task)
                                } label: {
                                    Text("Restore Origin Image")
                                }
                                .disabled(task.status != .completed)
                            } label: {
                                Image(systemName: "ellipsis.circle.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .frame(width: 20, height: 20)
                            }
                            .menuStyle(.borderlessButton)
                            .menuIndicator(.hidden)
                            .frame(width: 20, height: 20)
                            .tint(Color("textSecondary"))
                        }

                        // File size
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

                                if let outputType = task.outputType {
                                    Spacer()
                                        .frame(width: 2)

                                    TypeConvertTag(type: outputType.toDisplayName())
                                }
                            }
                        }
                    }

                    Spacer()
                        .frame(minHeight: 0)

                    HStack(spacing: 2) {
                        if task.status == .completed {
                            Button {
                                NSWorkspace.shared.open(task.outputUrl!.deletingLastPathComponent())
                            } label: {
                                Image(systemName: "folder.circle.fill")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color("textSecondary"))
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .help("Reveal Compressed Image in Finder")
                        }

                        Spacer()

                        Text(task.statusText())
                            .font(.system(size: 12, weight: statusTextWeight(task.status)))
                            .foregroundStyle(statusTextColor(task.status))
                    }
                    .frame(height: 16)
                    .padding(.trailing, 2)
                }
            }
            .padding(rowPadding)
            .frame(height: imageSize + rowPadding * 2)
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

struct TypeConvertTag: View {
    let type: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "repeat")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color("textSecondary"))

            Text(type)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(Color("textSecondary"))
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(
            Color.clear
                .overlay(
                    Capsule()
                        .stroke(Color("taskRowStroke"), lineWidth: 1)
                )
        )
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
//     TaskRowView(vm: MainViewModel(), task: Binding(get: {
//         TaskInfo(originUrl: URL(filePath: "/Users"))
//     }, set: { _ in
//
//     }), last: false)
//     .frame(height: 76)
// }
