import Foundation

public struct OptionalTypeNameComponents: OptionSet {

    public let rawValue: UInt

    public static var moduleName = Self(rawValue: 1 << 0)
    public static var nestingTypeNames = Self(rawValue: 1 << 1)
    public static var genericTypeParameterNames = Self(rawValue: 1 << 2)

    public static var all: Self = [
        .moduleName,
        .nestingTypeNames,
        .genericTypeParameterNames
    ]

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

extension Limn {

    private static let isFullyQualifiedTypeNameRegex = try? NSRegularExpression(
        pattern: #"^\w+(\.\w+)+(?![^<])"#,
        options: []
    )
    private static let typeNameRegex = try? NSRegularExpression(
        pattern: #"^([^.<]+\.)?((?>[^.<]+\.)*)([^.<]+)?(?><(.*)>)?$"#, // 4 capture groups
        options: []
    )

    static func isFullyQualifiedTypeName<S: StringProtocol>(_ name: S) -> Bool {
        isFullyQualifiedTypeNameRegex?.matches(in: name).isEmpty != true
    }

    static func format(propertyName name: String) -> String {

        if name.starts(with: "$__lazy_storage_$_") {
            return String(name.suffix(name.count - 18))
        } else {
            return name
        }
    }

    static func format<S: StringProtocol>(
        typeName name: S,
        including components: OptionalTypeNameComponents
    ) -> String {

        guard components != .all, let matches = Self.typeNameRegex?.matches(in: name).first else {
            return String(name)
        }

        var formatted = ""

        if components.contains(.moduleName) { formatted += matches[1] }
        if components.contains(.nestingTypeNames) { formatted += matches[2] }
        formatted += matches[3]
        if components.contains(.genericTypeParameterNames) && !matches[4].isEmpty {

            var genericTypeParameterList = [""]
            var bracketNestingLevel = 0

            for character in matches[4] {
                if character == "<" { bracketNestingLevel += 1 }
                else if character == ">" { bracketNestingLevel -= 1 }
                if bracketNestingLevel == 0 && character == "," {
                    genericTypeParameterList.append("")
                } else {
                    genericTypeParameterList[genericTypeParameterList.count - 1].append(character)
                }
            }

            let genericTypeParameters = genericTypeParameterList
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { format(typeName: $0, including: components) }
                .joined(separator: ", ")

            formatted += "<" + genericTypeParameters + ">"
        }

        return formatted
    }

    var nonFullyQualifiedTypeNames: [String] {

        switch self {
        case .class(name: let name, _, properties: let properties):
            return (Self.isFullyQualifiedTypeName(name) ? [] : [name]) +
                properties.flatMap(\.value.nonFullyQualifiedTypeNames)

        case .collection(elements: let elements):
            return elements.flatMap(\.nonFullyQualifiedTypeNames)

        case .dictionary(keyValuePairs: let keyValuePairs):
            return keyValuePairs.flatMap(\.key.nonFullyQualifiedTypeNames) +
                keyValuePairs.flatMap(\.value.nonFullyQualifiedTypeNames)

        case .enum(name: let name, _, associatedValue: let associatedValue):
            return (Self.isFullyQualifiedTypeName(name) ? [] : [name]) +
                (associatedValue?.nonFullyQualifiedTypeNames ?? [])

        case .optional(value: let value):
            return value?.nonFullyQualifiedTypeNames ?? []

        case .set(elements: let elements):
            return elements.flatMap(\.nonFullyQualifiedTypeNames)

        case .struct(name: let name, properties: let properties):
            return (Self.isFullyQualifiedTypeName(name) ? [] : [name]) +
                properties.flatMap(\.value.nonFullyQualifiedTypeNames)

        case .tuple(elements: let elements):
            return elements.flatMap(\.value.nonFullyQualifiedTypeNames)

        case .value,
             .omitted:
            return []
        }
    }
}
