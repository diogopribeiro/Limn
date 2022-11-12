// MARK: - Type value descriptions

enum ObjCValue { }

#if canImport(UIKit) && !os(watchOS)

import UIKit

extension ObjCValue {

    static let viewTypeValue: TestModel<UIView.Type> = (
        UIView.self,
        .value(description: "UIKit.UIView.Type")
    )
}

#elseif canImport(AppKit)

import AppKit

extension ObjCValue {

    static let viewTypeValue: TestModel<NSView.Type> = (
        NSView.self,
        .value(description: "AppKit.NSView.Type")
    )
}

#elseif canImport(WatchKit)

import WatchKit

extension ObjCValue {

    static let viewTypeValue: TestModel<WKInterfaceLabel.Type> = (
        WKInterfaceLabel.self,
        .value(description: "WatchKit.WKInterfaceLabel.Type")
    )
}

#endif
