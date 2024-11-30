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

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("TinyPNG service")

                HStack {
                    Text("API key")

                    TextField("apikey", text: $apiKey)
                }

                HStack(alignment: .top) {
                    Text("Preserve")

                    VStack(alignment: .leading) {
                        Toggle("Copyright", isOn: $preserveCopyright)
                        Toggle("Creation", isOn: $preserveCreation)
                        Toggle("Location", isOn: $preserveLocation)
                    }
                }

                Spacer()
                    .frame(height: 16)

                Text("Tasks")

                HStack {
                    Text("Concurrent task count")

                    Picker("", selection: $concurrentCount) {
                        ForEach(concurrentCountOptions, id: \.self) { count in
                            Text("\(count)").tag(count)
                        }
                    }
                }

                HStack(alignment: .top) {
                    Text("Replace origin image")

                    Toggle("", isOn: $replaceMode)
                }

                Spacer()
            }.padding(36)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        }
                }
        }
        .padding(24)
        .onDisappear {
            AppContext.shared.appConfig.update()
        }
    }
}
