////
//  Settings.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/12/1.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppConfig.key_apiKey) var apiKey: String = ""
    @AppStorage(AppConfig.key_proxyType) var proxyType: String = AppContext.shared.appConfig.proxyConfig.type.rawValue
    @AppStorage(AppConfig.key_proxyServer) var proxyServer: String = AppContext.shared.appConfig.proxyConfig.server
    @AppStorage(AppConfig.key_proxyPort) var proxyPort: String = AppContext.shared.appConfig.proxyConfig.portText
    @AppStorage(AppConfig.key_proxyUsername) var proxyUsername: String = AppContext.shared.appConfig.proxyConfig.username
    @AppStorage(AppConfig.key_proxyPassword) var proxyPassword: String = AppContext.shared.appConfig.proxyConfig.password

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

    @State private var contentSize: CGSize = CGSize.zero

    private let proxyTypeOptions = ProxyType.allCases

    var body: some View {
        VStack(alignment: .leading) {
            // Used to make sure content meature correctly
            ScrollView {
                // Content of Settings
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

                    SettingsItem(title: "Proxy:", desc: "Supports HTTP and SOCKS5 proxies. Authentication is optional.") {
                        VStack(alignment: .leading, spacing: 8) {
                            Picker("", selection: $proxyType) {
                                ForEach(proxyTypeOptions, id: \.self) { type in
                                    Text(type.rawValue).tag(type.rawValue)
                                }
                            }
                            .padding(.leading, -8)
                            .frame(maxWidth: 120)

                            if proxyType != ProxyType.disabled.rawValue {
                                HStack(alignment: .top, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Server")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color("textSecondary"))

                                        TextField("127.0.0.1", text: $proxyServer)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Port")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color("textSecondary"))

                                        TextField("7890", text: $proxyPort)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .frame(width: 96)
                                    }
                                }

                                HStack(alignment: .top, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Username")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color("textSecondary"))

                                        TextField("Optional", text: $proxyUsername)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Password")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color("textSecondary"))

                                        SecureField("Optional", text: $proxyPassword)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                }
                            }
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
                        .frame(maxWidth: 60)
                    }

                    SettingsItem(title: "Save Mode:", desc: "Overwrite Mode:\nThe compressed image will replace the original file. The original image is kept temporarily and can be restored before exit the app.\n\nSave As Mode:\nThe compressed image is saved as a new file, leaving the original image unchanged. You can choose where to save the compressed images.") {
                        Picker("", selection: $saveMode) {
                            ForEach(saveModeOptions, id: \.self) { mode in
                                Text(mode).tag(mode)
                            }
                        }
                        .padding(.leading, -8)
                        .frame(maxWidth: 120)
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
                        }
                    }

                    if AppContext.shared.isDebug {
                        Button {
                            AppContext.shared.appConfig.clearOutputFolder()
                        } label: {
                            Text("[D]Clear output directory")
                        }
                    }
                }
                .padding(24)
                .frame(width: 540)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                contentSize = proxy.size
                            }
                            .onChange(of: proxy.size) { newSize in
                                contentSize = newSize
                            }
                    }
                }
            }
            .scrollDisabled(true)
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
        // Set the size of window.
        .frame(width: contentSize.width + 32, height: contentSize.height + 32)
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
