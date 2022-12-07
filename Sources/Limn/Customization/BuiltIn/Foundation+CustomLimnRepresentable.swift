import Foundation

extension NSString: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "Foundation.\(NSStringFromClass(self)).Type"
    }

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        .class(
            name: Limn.typeName(of: self),
            address: Limn.address(of: self),
            properties: [
                .init(
                    "_stringRepresentation",
                    .value(description: "\"\(self.description)\"")
                )
            ]
        )
    }
}

extension NSURL: CustomLimnRepresentable {

    public static var customLimnTypeName: String {
        "Foundation.\(NSStringFromClass(self)).Type"
    }

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        .class(
            name: Limn.typeName(of: self),
            address: Limn.address(of: self),
            properties: [
                .init(
                    "_baseURL",
                    Limn(of: baseURL, maxDepth: context.maxDepth - context.currentDepth)
                ),
                .init(
                    "_urlString",
                    absoluteString.flatMap { Limn.value(description: "\"\($0)\"") } ?? .optional(value: nil)
                )
            ]
        )
    }
}
