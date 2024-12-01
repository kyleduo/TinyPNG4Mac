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

    @AppStorage(AppConfig.key_concurrentTaskCount) var concurrentCount: Int = 1
    let concurrentCountOptions = Array(1 ... 6)

    @AppStorage(AppConfig.key_replaceMode) var replaceMode: Bool = false
    @State var outputFilepath: String = AppContext.shared.appConfig.outputFolderUrl?.rawPath() ?? ""

    @FocusState private var isTextFieldFocused: Bool

    @State private var selectFilepathError: Error? = nil
    @State private var showSelectOutputFolder: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("TinyPNG")
                        .font(.system(size: 13, weight: .bold))

                    SettingsItem(title: "API key:", desc: "Visit [https://tinypng.com/developers](https://tinypng.com/developers) to request an API key.") {
                        TextField("apikey", text: $apiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isTextFieldFocused)
                            .onAppear {
                                isTextFieldFocused = false
                            }
                    }

                    SettingsItem(title: "Preserve:", desc: "") {
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

                    SettingsItem(title: "Parallelled tasks:", desc: "") {
                        Picker("", selection: $concurrentCount) {
                            ForEach(concurrentCountOptions, id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .padding(.leading, -8)
                        .frame(maxWidth: 80)
                    }

                    SettingsItem(title: "Replace mode:", desc: "By enabling replace mode, the compressed image will override the origin image file. TinyPNG4Mac will keep the origin image file in current App session for you can restore.") {
                        Toggle(replaceMode ? "Enabled" : "Disabled", isOn: $replaceMode)
                    }

                    SettingsItem(title: "Output folder:", desc: "If replace mode is disabled, the compressed images will be saved to this folder. If there're images with same name, the latest image will override previous one.") {
                        HStack(alignment: .top) {
                            Text(outputFilepath.isEmpty ? "--" : outputFilepath)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                showOpenPanel()
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
                }.padding(36)
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
        .padding(24)
        .onChange(of: replaceMode) { newValue in
            if !newValue && outputFilepath.isEmpty {
                showSelectOutputFolder = true
            }
        }
        .onDisappear {
            AppContext.shared.appConfig.update()
        }
        .alert("Fail to select file path", isPresented: Binding(get: { selectFilepathError != nil }, set: { _ in selectFilepathError = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Plase try to select another folder.")
        }
        .alert("Select output folder", isPresented: $showSelectOutputFolder) {
            Button("OK") {
                DispatchQueue.main.async {
                    showOpenPanel()
                }
            }
        } message: {
            Text("Plase select output folder.")
        }
    }

    private func showOpenPanel() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = true
        openPanel.prompt = "Select output directory"

        openPanel.begin { result in
            if result == .OK, let url = openPanel.url {
                print("User granted access to: \(url.rawPath())")

                do {
                    try AppContext.shared.appConfig.saveBookmark(for: url)
                    outputFilepath = url.rawPath()
                } catch {
                    selectFilepathError = error
                }
            } else {
                print("User did not grant access.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
