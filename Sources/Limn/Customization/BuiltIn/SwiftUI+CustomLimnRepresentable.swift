#if canImport(SwiftUI)

import SwiftUI

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
extension ButtonRole: CustomLimnRepresentable {

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        switch self {
        case Self.cancel:
            return .enum(name: Limn.typeName(of: self), caseName: "cancel")

        case Self.destructive:
            return .enum(name: Limn.typeName(of: self), caseName: "destructive")

        default:
            return defaultLimn()
        }
    }
}

#endif
