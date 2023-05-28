import Foundation

extension Limn {

    // MARK: - Types

    public struct SortOptions: OptionSet {

        public let rawValue: NSString.CompareOptions.RawValue

        /// Case-insensitive value comparison.
        public static var caseInsensitive = Self(rawValue: NSString.CompareOptions.caseInsensitive.rawValue)

        /// Compare numbers within strings using numeric value (e.g., "Name2.txt" < "Name7.txt" < "Name25.txt".)
        public static var numeric = Self(rawValue: NSString.CompareOptions.numeric.rawValue)

        public init(rawValue: NSString.CompareOptions.RawValue) {
            self.rawValue = rawValue
        }
    }

    public enum SortOrder {

        case ascending
        case descending

        fileprivate var comparisonResultValue: ComparisonResult {

            switch self {
            case .ascending:
                return .orderedAscending

            case .descending:
                return .orderedDescending
            }
        }
    }

    // MARK: - Public API

    /// Reorders all non-indexed elements using the specified criteria.
    ///
    /// This method will reorder class properties, struct properties, dictionary entries and set elements. Indexed
    /// items (collection types) and tuple properties will be left unchanged as their order may be syntactically
    /// relevant.
    ///
    /// - Parameters:
    ///   - order: The sorting order.
    ///   - options: Sorting options.
    /// - Returns: A `Limn` with its elements sorted.
    public func sorted(
        order: SortOrder = .ascending,
        options: SortOptions = .init([.caseInsensitive, .numeric])
    ) -> Self {

        sortedRecursively {
            $0.compare($1, options: .init(rawValue: options.rawValue)) == order.comparisonResultValue
        }
    }

    // MARK: - Private properties and methods

    private var sortComparisonString: String {

        switch self {
        case .class(name: let name, address: let address, properties: _):
            return "\(name).\(address).\(hashValue)"

        case .collection:
            return "[].\(hashValue)"

        case .dictionary:
            return "[:].\(hashValue)"

        case .enum(name: let name, caseName: let caseName, associatedValue: _):
            return "\(name).\(caseName).\(hashValue)"

        case .optional(value: let value):
            return value?.sortComparisonString ?? "."

        case .set:
            return "[].\(hashValue)"

        case .struct where isDiffStruct:
            let diff = diffValue
            return diff?.original?.sortComparisonString ?? diff?.update?.sortComparisonString ?? ""

        case .struct(name: let name, properties: _):
            return "\(name).\(hashValue)"

        case .tuple:
            return "().\(hashValue)"

        case .value(description: let description):
            return "\(description).\(hashValue)"

        case .omitted:
            return "\u{FFFF}" // Always the very last element
        }
    }

    private func sortedRecursively(using comparator: (String, String) -> Bool) -> Self {

        switch self {
        case .class(name: let name, address: let address, properties: let properties):
            let sortedProperties = properties
                .sorted(by: \.label, using: comparator)
                .map { LabeledLimn($0.label, $0.value.sortedRecursively(using: comparator)) }
            return .class(name: name, address: address, properties: sortedProperties)

        case .collection(elements: let elements):
            let sortedElements = elements.map { $0.sortedRecursively(using: comparator) }
            return .collection(elements: sortedElements)

        case .dictionary(keyValuePairs: let keyValuePairs):
            let sortedKeyValuePairs = keyValuePairs
                .sorted(by: \.key.sortComparisonString, using: comparator)
                .map { ($0.key.sortedRecursively(using: comparator), $0.value.sortedRecursively(using: comparator)) }
                .map { KeyedLimn($0.0, $0.1) }
            return .dictionary(keyValuePairs: sortedKeyValuePairs)

        case .enum(name: let name, caseName: let caseName, associatedValue: let associatedValue):
            let sortedAssociatedValue = associatedValue?.sortedRecursively(using: comparator)
            return .enum(name: name, caseName: caseName, associatedValue: sortedAssociatedValue)

        case .optional(value: let value):
            return .optional(value: value.map { $0.sortedRecursively(using: comparator) })

        case .set(elements: let elements):
            let sortedElements = elements
                .sorted(by: \.sortComparisonString, using: comparator)
                .map { $0.sortedRecursively(using: comparator) }
            return .set(elements: sortedElements)

        case .struct(name: let name, properties: let properties):
            let sortedProperties = properties
                .sorted(by: \.label, using: comparator)
                .map { LabeledLimn($0.label, $0.value.sortedRecursively(using: comparator)) }
            return .struct(name: name, properties: sortedProperties)

        case .tuple(elements: let elements):
            let sortedElements = elements
                .map { LabeledLimn($0.label, $0.value.sortedRecursively(using: comparator)) }
            return .tuple(elements: sortedElements)

        case .value,
             .omitted:
            return self
        }
    }
}
