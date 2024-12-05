//
//  SwiftUIModifiers.swift
//  EventTracker
//
//  Created by kyleduo on 2022/8/13.
//

import Foundation
import SwiftUI

struct NavigationLinkWithoutArrow<Destination>: ViewModifier where Destination: View {
    var destination: Destination

    func body(content: Content) -> some View {
        content
            .background(NavigationLink("", destination: destination).buttonStyle(.plain).opacity(0))
    }
}

struct HideScrollContentBackgroundIOS16: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
        } else {
            // Fallback on earlier versions
            content
        }
    }
}

extension View {
    func navigationLinkWithoutArrow<Destination: View>(destination: Destination) -> some View {
        return modifier(NavigationLinkWithoutArrow(destination: destination))
    }

    func padding(vertical: CGFloat, horizontal: CGFloat) -> some View {
        return padding(EdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal))
    }

    func clearListCellStyle() -> some View {
        return modifier(ClearListCellStyle())
    }

    /// iOS 16 默认会有纯色背景，用这个方法隐藏
    func hideScrollContentBackground() -> some View {
        return modifier(HideScrollContentBackgroundIOS16())
    }
    
    /// iOS 16 半高Sheet
    func mediumSheetView() -> some View {
        if #available(iOS 16.0, *) {
            return self
                .presentationDetents([.medium])
        } else {
            return self
        }
    }
}

struct ClearListCellStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
    }
}
