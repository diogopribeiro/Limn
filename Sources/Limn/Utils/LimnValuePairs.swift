/// Holds a `Limn` identified by a key of identical type.
public struct KeyedLimn: Hashable, Codable {

    public let key: Limn
    public let value: Limn

    public init(_ key: Limn, _ value: Limn) {
        self.key = key
        self.value = value
    }

    public static func omitted(reason: Limn.OmittedReason) -> Self {
        .init(.omitted(reason: reason), .omitted(reason: reason))
    }
}

/// Holds a `Limn` identified by a `String` label.
public struct LabeledLimn: Hashable, Codable {

    public let label: String
    public let value: Limn

    public init(_ label: String, _ value: Limn) {
        self.label = label
        self.value = value
    }

    public static func omitted(label: String = "", reason: Limn.OmittedReason) -> Self {
        .init(label, .omitted(reason: reason))
    }
}
