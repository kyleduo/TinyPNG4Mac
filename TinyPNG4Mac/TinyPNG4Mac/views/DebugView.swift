////
//  DebugView.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2025/1/12.
//

import SwiftUI

/// Display debug messages only in debug mode
struct DebugView: View {
    @EnvironmentObject var appContext: AppContext
    @EnvironmentObject var debugVM: DebugViewModel

    var body: some View {
        if appContext.isDebug {
            VStack(alignment: .trailing) {
                ForEach(debugVM.debugMessages, id: \.self) { msg in
                    Text(msg)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(vertical: 32, horizontal: 16)
        }
    }
}
