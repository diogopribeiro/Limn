#if canImport(AppKit)

import AppKit

// MARK: - AppKit Classes

extension NSView: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "AppKit.\(NSStringFromClass(self)).Type"
    }
}

#endif
