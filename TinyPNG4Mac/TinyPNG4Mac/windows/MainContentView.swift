//
//  ContentView.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/16.
//

import SwiftUI

struct MainContentView: View {
    @EnvironmentObject var appContext: AppContext
    @ObservedObject var vm: MainViewModel
    /// imageUrl : inputUrl
    @State private var dropResult: [URL: URL] = [:]
    @State private var showAlert = false
    @State private var showOpenPanel = false
    @State private var showRestoreAllConfirmAlert = false
    @State private var alertMessage: String? = nil
    @State private var showOutputDirectoryTips: Bool = false
    @State private var outputDirectoryButtonPosition: CGRect = CGRect.zero
    @State private var rootSize: CGSize = CGSize.zero
    @State private var hoverSaveModeButton: Bool = false
    @State private var showAutoConvertTypeTips: Bool = false
    @State private var autoConvertTypeTipsPosition: CGRect = CGRect.zero
    @State private var hoverConvertTypeMenu: Bool = false

    @AppStorage(AppConfig.key_saveMode) var saveMode: String = AppContext.shared.appConfig.saveMode

    var body: some View {
        ZStack {
            DropFileView(dropResult: $dropResult)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("mainViewBackground"))

            VStack(spacing: 0) {
                Text("Tiny Image")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color("textMainTitle"))
                    .frame(height: 28)

                if vm.tasks.isEmpty {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(
                                lineWidth: 2,
                                dash: [6, 3]
                            ))
                            .foregroundColor(Color.white.opacity(0.1))
                            .padding()

                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color("textCaption"))
                                .frame(width: 60, height: 60)
                                .padding(.bottom, 12)

                            Text("Drop images or folders here!")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color("textBody"))

                            Text("Supports WebP, PNG, and JPEG images.")
                                .font(.system(size: 10))
                                .foregroundStyle(Color("textSecondary"))
                        }
                    }
                    .frame(idealWidth: 360, maxWidth: .infinity, idealHeight: 360, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(vm.tasks.indices, id: \.self) { index in
                            TaskRowView(vm: vm, task: $vm.tasks[index], last: index == vm.tasks.count - 1)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                    .clipped()
                    .frame(maxWidth: appContext.maxSize.width)
                    .scrollContentBackground(.hidden)
                    .listStyle(PlainListStyle())
                    .environment(\.defaultMinListRowHeight, 0)
                }

                HorizontalDivider()
                    .padding(vertical: 0, horizontal: 12)
                    .padding(.top, 2)

                // Format converting
                HStack(spacing: 2) {
                    Text("Convert Images to:")
                        .font(.system(size: 12))
                        .foregroundStyle(Color("textCaption"))

                    Menu {
                        Button {
                            vm.targetConvertType = nil
                        } label: {
                            Text("Keep origin format")
                                .font(.system(size: 12))
                        }

                        Divider()

                        Button {
                            vm.targetConvertType = .auto
                        } label: {
                            Text("Auto")
                                .font(.system(size: 12))
                        }

                        Text("Use the smallest format automatically")
                            .font(.system(size: 10))

                        Divider()

                        ForEach(ImageType.allTypes, id: \.self) { type in
                            Button {
                                vm.targetConvertType = type
                            } label: {
                                Text(type.toDisplayName())
                                    .font(.system(size: 12))
                            }
                        }
                    } label: {
                        Text(vm.convertTypeName)
                            .font(.system(size: 12))
                            .foregroundStyle(Color("textSecondary"))
                            .frame(minWidth: 20)
                    }
                    .padding(vertical: 2, horizontal: 4)
                    .background {
                        if hoverConvertTypeMenu {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.15))
                        } else {
                            Color.clear
                        }
                    }
                    .onHover { hover in
                        hoverConvertTypeMenu = hover
                    }
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.hidden)
                    .fixedSize(horizontal: true, vertical: false)

                    if vm.targetConvertType == .auto {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color("textSecondary"))
                            .background {
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            autoConvertTypeTipsPosition = proxy.frame(in: .named("root"))
                                        }
                                        .onChange(of: proxy.frame(in: .named("root"))) { newFrame in
                                            autoConvertTypeTipsPosition = newFrame
                                        }
                                }
                            }
                            .onHover { hover in
                                showAutoConvertTypeTips = hover
                            }
                    }

                    Spacer()
                }
                .padding(vertical: 8, horizontal: 12)

                HorizontalDivider()
                    .padding(vertical: 0, horizontal: 12)
                    .padding(.top, 2)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        KeyValueLabel(key: "Total:", value: "\(vm.tasks.count) tasks, \(vm.totalOriginSize.formatBytes())")

                        KeyValueLabel(key: "Completed:", value: "\(vm.completedTaskCount) tasks, \(vm.totalFinalSize.formatBytes())")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 2) {
                        Text("Save Mode:")
                            .font(.system(size: 12))
                            .foregroundStyle(Color("textCaption"))

                        settingButton(useButtonStyle: false) {
                            Text(LocalizedStringKey(saveMode))
                                .font(.system(size: 12))
                                .foregroundStyle(Color("textSecondary"))
                                .padding(vertical: 2, horizontal: 4)
                                .background {
                                    if hoverSaveModeButton {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.white.opacity(0.15))
                                    } else {
                                        Color.clear
                                    }
                                }
                                .onHover { hover in
                                    hoverSaveModeButton = hover
                                }
                        }
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 0, trailing: 12))

                HStack(alignment: .bottom, spacing: 6) {
                    let usedQuota = vm.monthlyUsedQuota >= 0 ? String(vm.monthlyUsedQuota) : "--"
                    Text("Images compressed this month: \(usedQuota)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color("textSecondary"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if saveMode == AppConfig.saveModeNameSaveAs {
                        Button {
                            if let outputDir = appContext.appConfig.outputDirectoryUrl {
                                if outputDir.fileExists() {
                                    NSWorkspace.shared.open(outputDir)
                                } else {
                                    alertMessage = String(localized: "The output directory does not exist. It will be automatically created after any task is completed.")
                                }
                            } else {
                                vm.settingsNotReadyMessage = String(localized: "Output directory is not set yet, please select it in the settings window.")
                            }
                        } label: {
                            Image(systemName: "folder.circle.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color("textSecondary"))
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background {
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        outputDirectoryButtonPosition = proxy.frame(in: .named("root"))
                                    }
                                    .onChange(of: proxy.frame(in: .named("root"))) { newFrame in
                                        outputDirectoryButtonPosition = newFrame
                                    }
                            }
                        }
                        .onHover { hover in
                            showOutputDirectoryTips = hover
                        }
                    }

                    menuEntry()
                }.padding(EdgeInsets(top: 6, leading: 12, bottom: 12, trailing: 12))
            }

            DebugView()

            if let outputDir = appContext.appConfig.outputDirectoryUrl, showOutputDirectoryTips {
                TipsView(message: String(localized: "Click to open: ") + "\n\(outputDir.rawPath())", alignCenterOrRight: false, rootSize: $rootSize, anchorViewFrame: $outputDirectoryButtonPosition)
            }

            if showAutoConvertTypeTips {
                TipsView(message: String(localized: "Use the smallest format automatically"), alignCenterOrRight: true, rootSize: $rootSize, anchorViewFrame: $autoConvertTypeTipsPosition)
            }
        }
        .coordinateSpace(name: "root")
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        rootSize = proxy.size
                    }
                    .onChange(of: proxy.size) { newSize in
                        rootSize = newSize
                    }
            }
        }
        .ignoresSafeArea()
        .onChange(of: dropResult) { newValue in
            if !newValue.isEmpty {
                dropResult = [:]
                vm.createTasks(imageURLs: newValue)
            }
        }
        .alert("Confirm to restore the image?",
               isPresented: Binding(
                   get: { vm.restoreConfirmTask != nil },
                   set: { if !$0 { } }
               ),
               actions: {
                   Button("Restore") { vm.restoreConfirmConfirmed() }
                   Button("Cancel", role: .cancel) { vm.restoreConfirmCancel() }
               },
               message: {
                   let path = vm.restoreConfirmTask == nil ? "" : vm.restoreConfirmTask?.originUrl.rawPath() ?? ""
                   Text("The image at \"\(path)\" will be replaced with the origin file.")
                       .font(.system(size: 12))
               }
        )
        .alert("The config is not ready",
               isPresented: Binding(
                   get: { vm.settingsNotReadyMessage != nil },
                   set: { if !$0 { vm.settingsNotReadyMessage = nil } }
               ),
               actions: {
                   settingButton(title: "Open Settings")
                   Button("Cancel", role: .cancel) { }
               },
               message: {
                   if let message = vm.settingsNotReadyMessage {
                       Text(message)
                   }
               }
        )
        .alert("Confirm to restore all the images?",
               isPresented: $showRestoreAllConfirmAlert,
               actions: {
                   Button("Restore") {
                       vm.restoreAll()
                   }
                   Button("Cancel", role: .cancel) { }
               },
               message: {
                   Text("All compressed images will be replaced with the origin file.")
               }
        )
        .alert("Confirm quit?",
               isPresented: $vm.showQuitWithRunningTasksAlert,
               actions: {
                   Button("Quit") {
                       vm.cancelAllTask()
                       NSApplication.shared.terminate(nil)
                   }
                   Button("Cancel", role: .cancel) {}
               },
               message: {
                   Text("There are ongoing tasks. Quitting will cancel them all.")
               })
        .alert(alertMessage ?? "",
               isPresented: Binding(
                   get: { alertMessage != nil },
                   set: { if !$0 { alertMessage = nil } }
               ),
               actions: {
                   Button("OK") { }
               }
        )
    }

    private func settingButton(title: String) -> some View {
        settingButton {
            Text(title)
        }
    }

    private func settingButton(useButtonStyle: Bool = true, @ViewBuilder view: () -> some View) -> some View {
        if #available(macOS 14.0, *) {
            AnyView(
                SettingsLink {
                    view()
                }
                .modifier(PlainButtonStyleModifier(plainButtonStyle: !useButtonStyle))
            )
        } else {
            AnyView(
                Button {
                    if #available(macOS 13.0, *) {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } else {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                } label: {
                    view()
                }
                .modifier(PlainButtonStyleModifier(plainButtonStyle: !useButtonStyle))
            )
        }
    }

    private func menuEntry() -> some View {
        Menu {
            Button {
                vm.retryAllFailedTask()
            } label: {
                Text("Retry all failed tasks")
            }
            .disabled(vm.failedTaskCount == 0)

            Divider()

            Button {
                vm.clearAllTask()
            } label: {
                Text("Clear all tasks")
            }
            .disabled(vm.tasks.count == 0)

            Button {
                vm.clearFinishedTask()
            } label: {
                Text("Clear all finished tasks")
            }
            .disabled(vm.tasks.count == 0)

            Divider()

            Button {
                showRestoreAllConfirmAlert = true
            } label: {
                Text("Restore all compressed images")
            }
            .disabled(vm.completedTaskCount == 0)
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

    private func outputDirExist() -> Bool {
        if let outputDir = appContext.appConfig.outputDirectoryUrl {
            return outputDir.fileExists()
        }
        return false
    }
}

struct TipsView: View {
    let message: String
    let alignCenterOrRight: Bool

    @Binding var rootSize: CGSize
    @Binding var anchorViewFrame: CGRect

    @State private var tipsSize: CGSize = CGSize.zero

    var body: some View {
        Text(message)
            .font(.system(size: 12))
            .foregroundStyle(Color("textBody"))
            .lineLimit(2)
            .padding(vertical: 6, horizontal: 12)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.8))
            }
            .padding(.leading, 12)
            .padding(.trailing, 12)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            tipsSize = proxy.size
                        }
                        .onChange(of: proxy.size) { newSize in
                            tipsSize = newSize
                        }
                }
            }
            .position(x: alignCenterOrRight ? anchorViewFrame.origin.x + anchorViewFrame.width / 2 : rootSize.width / 2 + (rootSize.width - tipsSize.width) / 2, y: anchorViewFrame.origin.y - tipsSize.height / 2 - 4)
    }
}

struct KeyValueLabel: View {
    var key: LocalizedStringKey
    var value: LocalizedStringKey

    var body: some View {
        HStack(spacing: 2) {
            Text(key)
                .font(.system(size: 12))
                .foregroundStyle(Color("textCaption"))

            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(Color("textSecondary"))
        }
    }
}

struct PlainButtonStyleModifier: ViewModifier {
    var plainButtonStyle: Bool

    func body(content: Content) -> some View {
        if plainButtonStyle {
            content.buttonStyle(PlainButtonStyle())
        } else {
            content
        }
    }
}
