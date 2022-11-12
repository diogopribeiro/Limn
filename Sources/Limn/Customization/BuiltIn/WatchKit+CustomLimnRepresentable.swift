#if canImport(WatchKit)

import WatchKit

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
extension WKInterfaceLabel: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "WatchKit.\(NSStringFromClass(self)).Type"
    }
}

#endif
