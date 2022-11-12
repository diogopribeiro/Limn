/// A representation of the substructure, display style and values of an instance of any type.
///
/// To customize the `Limn` representation of a type, add conformance to the `CustomLimnRepresentable` protocol.
public indirect enum Limn: Hashable, Codable {

    public enum OmittedReason: Codable {

        /// Type was filtered out.
        case filtered

        /// `Limn` was unable to parse the type.
        case unresolved

        /// Maximum recursion level was exceeded while obtaining the `Limn` of a child member.
        case maxDepthExceeded

        /// A reference cycle was detected and `Limn` skipped this value to avoid infinite recursion.
        case referenceCycleDetected
    }

    case `class`(name: String, address: String, properties: [LabeledLimn])
    case collection(elements: [Self])
    case dictionary(keyValuePairs: [KeyedLimn])
    case `enum`(name: String, caseName: String, associatedValue: Limn? = nil)
    case optional(value: Self?)
    case set(elements: [Self])
    case `struct`(name: String, properties: [LabeledLimn])
    case tuple(elements: [LabeledLimn])
    case value(description: String)

    case omitted(reason: OmittedReason)
}

extension Limn {

    /// Creates a new `Limn` representing the given instance.
    ///
    /// - Parameters:
    ///   - value: The instance for which to create a `Limn`.
    ///   - maxDepth: The maximum level of recursion to use when resolving the `Limn` of child members of the passed
    ///     instance. Child values beyond this level will always be equal to `.omitted(reason: .maxDepthExceeded)`. The
    ///     default value for this property is `Int.max`.
    public init<V>(of value: V, maxDepth: Int = .max) {

        let context = InitContext(currentDepth: 1, maxDepth: maxDepth, parentClassAddresses: .init())
        self = .init(of: value, context: context)
    }
}
