////
//  Settings.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/12/1.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppConfig.key_apiKey) var apiKey: String = ""

    @AppStorage(AppConfig.key_preserveCopyright) var preserveCopyright: Bool = false
    @AppStorage(AppConfig.key_preserveCreation) var preserveCreation: Bool = false
    @AppStorage(AppConfig.key_preserveLocation) var preserveLocation: Bool = false

    @AppStorage(AppConfig.key_concurrentTaskCount) var concurrentCount: Int = AppContext.shared.appConfig.concurrentTaskCount
    private let concurrentCountOptions = Array(1 ... 6)
    
    @AppStorage(AppConfig.key_saveMode) var saveMode: String = AppContext.shared.appConfig.saveMode
    private let saveModeOptions = AppConfig.saveModeKeys
    
    @AppStorage(AppConfig.key_outputDirectory)
    var outputDirectory: String = AppContext.shared.appConfig.outputDirectoryUrl?.rawPath() ?? ""

    @FocusState private var isTextFieldFocused: Bool

    @State private var failedToSelectOutputDirectory: Bool = false
    @State private var enableSaveAsModeAfterSelect: Bool = false
    @State private var showSelectOutputFolder: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("TinyPNG")
                        .font(.system(size: 13, weight: .bold))

                    SettingsItem(title: "API key:", desc: "Visit [https://tinypng.com/developers](https://tinypng.com/developers) to request an API key.") {
                        TextField("", text: $apiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isTextFieldFocused)
                            .onAppear {
                                isTextFieldFocused = false
                            }
                    }

                    SettingsItem(title: "Preserve:", desc: nil) {
                        VStack(alignment: .leading) {
                            Toggle("Copyright", isOn: $preserveCopyright)
                            Toggle("Creation", isOn: $preserveCreation)
                            Toggle("Location", isOn: $preserveLocation)
                        }
                    }

                    Spacer()
                        .frame(height: 16)

                    Text("Tasks")
                        .font(.system(size: 13, weight: .bold))

                    SettingsItem(title: "Concurrent tasks:", desc: nil) {
                        Picker("", selection: $concurrentCount) {
                            ForEach(concurrentCountOptions, id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .padding(.leading, -8)
                        .frame(maxWidth: 160)
                    }

                    SettingsItem(title: "Save Mode:", desc: "Overwrite Mode:\nThe compressed image will replace the original file. The original image is kept temporarily and can be restored before exit the app.\n\nSave As Mode:\nThe compressed image is saved as a new file, leaving the original image unchanged. You can choose where to save the compressed images.") {
                        Picker("", selection: $saveMode) {
                            ForEach(saveModeOptions, id: \.self) { mode in
                                Text(mode).tag(mode)
                            }
                        }
                        .padding(.leading, -8)
                        .frame(maxWidth: 160)
                    }

                    SettingsItem(title: "Output directory:", desc: "When \"Save As Mode\" is enabled, the compressed image will be saved to this directory. If a file with the same name exists, it will be overwritten.") {
                        HStack(alignment: .top) {
                            Text(outputDirectory.isEmpty ? "--" : outputDirectory)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                showSelectFolderPanel()
                            } label: {
                                Text("Select...")
                            }

                            if AppContext.shared.isDebug {
                                Button {
                                    AppContext.shared.appConfig.clearOutputFolder()
                                } label: {
                                    Text("Clear")
                                }
                            }
                        }
                    }
                }.padding(24)
            }
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("settingViewBackground"))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("settingViewBackgroundBorder"), lineWidth: 1)
                    }
            }
        }
        .padding(16)
        .onChange(of: saveMode) { newValue in
            if newValue == AppConfig.saveModeNameSaveAs && outputDirectory.isEmpty {
                saveMode = AppConfig.saveModeNameOverwrite
                enableSaveAsModeAfterSelect = true
                showSelectOutputFolder = true
            }
        }
        .onDisappear {
            if outputDirectory.isEmpty {
                AppContext.shared.appConfig.clearOutputFolder()
            }
            AppContext.shared.appConfig.update()
        }
        .alert("Failed to save output directory",
               isPresented: $failedToSelectOutputDirectory
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please select a different directory.")
        }
        .alert("Select output directory", isPresented: $showSelectOutputFolder) {
            Button("OK") {
                DispatchQueue.main.async {
                    enableSaveAsModeAfterSelect = false
                    showSelectFolderPanel()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Disable \"Overwrite Mode\" after selecting the output directory.")
        }
    }

    private func showSelectFolderPanel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        panel.prompt = "Select"

        panel.begin { result in
            if result == .OK, let url = panel.url {
                print("User Select: \(url.rawPath())")
                outputDirectory = url.rawPath()
            } else {
                print("User did not grant access.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
