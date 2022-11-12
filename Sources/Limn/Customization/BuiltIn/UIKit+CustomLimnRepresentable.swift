#if canImport(UIKit) && !os(watchOS)

import UIKit

// MARK: - UIKit Classes

extension UITraitCollection: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.\(NSStringFromClass(self)).Type"
    }
}

extension UIView: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.\(NSStringFromClass(self)).Type"
    }
}

extension UIViewController: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.\(NSStringFromClass(self)).Type"
    }
}

// MARK: - UIKit Enums

extension UIControl.State: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.UIControl.State.Type"
    }

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        let caseName: String
        switch self {
        case .application: caseName = "application"
        case .disabled: caseName = "disabled"
        case .focused: caseName = "focused"
        case .highlighted: caseName = "highlighted"
        case .normal: caseName = "normal"
        case .reserved: caseName = "reserved"
        case .selected: caseName = "selected"
        default: caseName = "@unknown"
        }

        return .enum(name: Limn.typeName(of: self), caseName: caseName, associatedValue: nil)
    }
}

extension UIDeviceOrientation: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.UIDeviceOrientation.Type"
    }

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        let caseName: String
        switch self {
        case .unknown: caseName = "unknown"
        case .portrait: caseName = "portrait"
        case .portraitUpsideDown: caseName = "portraitUpsideDown"
        case .landscapeLeft: caseName = "landscapeLeft"
        case .landscapeRight: caseName = "landscapeRight"
        case .faceUp: caseName = "faceUp"
        case .faceDown: caseName = "faceDown"
        @unknown default: caseName = "@unknown"
        }

        return .enum(name: Limn.typeName(of: self), caseName: caseName, associatedValue: nil)
    }
}

extension UIGestureRecognizer.State: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.UIGestureRecognizer.State.Type"
    }

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        let caseName: String
        switch self {
        case .began: caseName = "began"
        case .cancelled: caseName = "cancelled"
        case .changed: caseName = "changed"
        case .ended: caseName = "ended"
        case .failed: caseName = "failed"
        case .possible: caseName = "possible"
        @unknown default: caseName = "@unknown"
        }

        return .enum(name: Limn.typeName(of: self), caseName: caseName, associatedValue: nil)
    }
}

@available(iOS 11.0, *)
extension UIScrollView.ContentInsetAdjustmentBehavior: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.UIScrollView.ContentInsetAdjustmentBehavior.Type"
    }

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        let caseName: String
        switch self {
        case .always: caseName = "always"
        case .automatic: caseName = "automatic"
        case .never: caseName = "never"
        case .scrollableAxes: caseName = "scrollableAxes"
        @unknown default: caseName = "@unknown"
        }

        return .enum(name: Limn.typeName(of: self), caseName: caseName, associatedValue: nil)
    }
}

extension UIStackView.Alignment: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.UIStackView.Alignment.Type"
    }

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        let caseName: String
        switch self {
        case .fill: caseName = "fill"
        case .leading: caseName = "leading"
        case .firstBaseline: caseName = "firstBaseline"
        case .center: caseName = "center"
        case .trailing: caseName = "trailing"
        case .lastBaseline: caseName = "lastBaseline"
        @unknown default: caseName = "@unknown"
        }

        return .enum(name: Limn.typeName(of: self), caseName: caseName, associatedValue: nil)
    }
}

extension UIStackView.Distribution: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.UIStackView.Distribution.Type"
    }

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        let caseName: String
        switch self {
        case .fill: caseName = "fill"
        case .fillEqually: caseName = "fillEqually"
        case .fillProportionally: caseName = "fillProportionally"
        case .equalSpacing: caseName = "equalSpacing"
        case .equalCentering: caseName = "equalCentering"
        @unknown default: caseName = "@unknown"
        }

        return .enum(name: Limn.typeName(of: self), caseName: caseName, associatedValue: nil)
    }
}

extension UIView.ContentMode: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.UIView.ContentMode.Type"
    }

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        let caseName: String
        switch self {
        case .bottom: caseName = "bottom"
        case .bottomLeft: caseName = "bottomLeft"
        case .bottomRight: caseName = "bottomRight"
        case .center: caseName = "center"
        case .left: caseName = "left"
        case .redraw: caseName = "redraw"
        case .right: caseName = "right"
        case .scaleAspectFill: caseName = "scaleAspectFill"
        case .scaleAspectFit: caseName = "scaleAspectFit"
        case .scaleToFill: caseName = "scaleToFill"
        case .top: caseName = "top"
        case .topLeft: caseName = "topLeft"
        case .topRight: caseName = "topRight"
        @unknown default: caseName = "@unknown"
        }

        return .enum(name: Limn.typeName(of: self), caseName: caseName, associatedValue: nil)
    }
}

extension UIView.TintAdjustmentMode: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "UIKit.UIView.TintAdjustmentMode.Type"
    }

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        let caseName: String
        switch self {
        case .automatic: caseName = "automatic"
        case .normal: caseName = "normal"
        case .dimmed: caseName = "dimmed"
        @unknown default: caseName = "@unknown"
        }

        return .enum(name: Limn.typeName(of: self), caseName: caseName, associatedValue: nil)
    }
}

#endif
