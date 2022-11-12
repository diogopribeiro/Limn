extension Limn {

    // MARK: - Types

    public enum UndiffDirection {
        case original
        case update
    }

    // MARK: - Public API

    /// Removes diffing information from a `Limn` by reverting it to either the 'original' or 'updated' value.
    ///
    /// - Parameter direction: The undiff direction to apply.
    /// - Returns: The `Limn` instance without diffing information, or `nil` if the value was added but the original
    ///   value was requested or the value was removed but the updated value was requested.
    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    public func undiffed(to direction: UndiffDirection) -> Limn? {

        switch self {
        case .struct where isDiffStruct:
            guard let diff = Diff(from: self) else {
                assertionFailure()
                return nil
            }

            switch direction {
            case .original:
                return diff.original?.undiffed(to: .original)
            case .update:
                return diff.update?.undiffed(to: .update)
            }

        case .class(name: let name, address: let address, properties: let properties):
            let undiffedProperties = properties.compactMap { property -> LabeledLimn? in
                guard let undiffedValue = property.value.undiffed(to: direction) else { return nil }
                return LabeledLimn(property.label, undiffedValue)
            }
            return .class(name: name, address: address, properties: undiffedProperties)

        case .collection(elements: let elements):
            let undiffedElements = elements.compactMap { $0.undiffed(to: direction) }
            return .collection(elements: undiffedElements)

        case .dictionary(keyValuePairs: let keyValuePairs):
            let undiffedKeyValuePairs = keyValuePairs.compactMap { keyValuePair -> KeyedLimn? in
                guard let undiffedKey = keyValuePair.key.undiffed(to: direction) else { return nil }
                guard let undiffedValue = keyValuePair.value.undiffed(to: direction) else { return nil }
                guard undiffedKey != .optional(value: nil), undiffedValue != .optional(value: nil) else { return nil }
                return KeyedLimn(undiffedKey, undiffedValue)
            }
            return .dictionary(keyValuePairs: undiffedKeyValuePairs)

        case .enum(name: let name, caseName: let caseName, associatedValue: let associatedValue):
            let undiffedAssociatedValue = associatedValue?.undiffed(to: direction)
            return .enum(name: name, caseName: caseName, associatedValue: undiffedAssociatedValue)

        case .optional(value: let value):
            return .optional(value: value?.undiffed(to: direction))

        case .set(elements: let elements):
            let undiffedElements = elements.compactMap { $0.undiffed(to: direction) }
            return .set(elements: undiffedElements)

        case .struct(name: let name, properties: let properties):
            let undiffedProperties = properties.compactMap { property -> LabeledLimn? in
                guard let undiffedValue = property.value.undiffed(to: direction) else { return nil }
                return LabeledLimn(property.label, undiffedValue)
            }
            return .struct(name: name, properties: undiffedProperties)

        case .tuple(elements: let elements):
            let undiffedElements = elements.compactMap { element -> LabeledLimn? in
                guard let undiffedValue = element.value.undiffed(to: direction) else { return nil }
                return LabeledLimn(element.label, undiffedValue)
            }
            return .tuple(elements: undiffedElements)

        case .value,
             .omitted:
            return self
        }
    }
}
