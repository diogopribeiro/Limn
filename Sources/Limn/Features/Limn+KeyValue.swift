extension Limn {

    /// Returns the `Limn` for the property identified by a given key.
    ///
    /// The keys may have different meanings depending on the type:
    /// - For classes and structs, a key identifies a property.
    /// - For collections, keys identify the index (e.g. "1").
    /// - For dictionaries, a key identifies a key from the dictionary (simple value types only).
    /// - For enums with associated values, keys identify the label of the value or its index.
    /// - For sets, a key identifies the description on value types.
    /// - For tuples, keys identify the label of a value or its index.
    /// - All other types will return `nil`.
    ///
    /// - Parameter key: The key for the desired property.
    /// - Returns: The `Limn` matching the specified key, or `nil` if it does not exist.
    public subscript(_ key: Double) -> Limn? {
        self["\(key)"]
    }

    /// Returns the `Limn` for the property identified by a given key.
    ///
    /// The keys may have different meanings depending on the type:
    /// - For classes and structs, a key identifies a property.
    /// - For collections, keys identify the index (e.g. "1").
    /// - For dictionaries, a key identifies a key from the dictionary (simple value types only).
    /// - For enums with associated values, keys identify the label of the value or its index.
    /// - For sets, a key identifies the description on value types.
    /// - For tuples, keys identify the label of a value or its index.
    /// - All other types will return `nil`.
    ///
    /// - Parameter key: The key for the desired property.
    /// - Returns: The `Limn` matching the specified key, or `nil` if it does not exist.
    public subscript(_ key: Int) -> Limn? {
        self["\(key)"]
    }

    /// Returns the `Limn` for the property identified by a given key.
    ///
    /// The keys may have different meanings depending on the type:
    /// - For classes and structs, a key identifies a property.
    /// - For collections, keys identify the index (e.g. "1").
    /// - For dictionaries, a key identifies a key from the dictionary (simple value types only).
    /// - For enums with associated values, keys identify the label of the value or its index.
    /// - For sets, a key identifies the description on value types.
    /// - For tuples, keys identify the label of a value or its index.
    /// - All other types will return `nil`.
    ///
    /// - Parameter key: The key for the desired property.
    /// - Returns: The `Limn` matching the specified key, or `nil` if it does not exist.
    public subscript<S: StringProtocol>(_ key: S) -> Limn? {

        guard !key.isEmpty else {
            return nil
        }

        switch self {
        case .class(_, _, properties: let properties):
            return properties.first(where: { $0.label == key })?.value

        case .collection(elements: let elements):
            return Int(key).flatMap { elements[safe: $0] }

        case .dictionary(keyValuePairs: let keyValuePairs):
            return firstIndex(in: keyValuePairs.map(\.key), ofValueWithDescription: key)
                .map { keyValuePairs[$0].value }

        case .enum(_, _, associatedValue: .some(.tuple(elements: let elements))):
            return Int(key).flatMap { elements[safe: $0]?.value } ??
                elements.first(where: { $0.label == key })?.value

        case .enum(_, _, associatedValue: .some(let associatedValue)):
            return key == "0" ? associatedValue : nil

        case .set(elements: let elements):
            return firstIndex(in: elements, ofValueWithDescription: key)
                .map { elements[$0] }

        case .struct where isDiffStruct:
            let diff = diffValue
            return Diff(original: diff?.original[key], update: diff?.update[key]).limnValue

        case .struct(_, properties: let properties):
            return properties.first(where: { $0.label == key })?.value

        case .tuple(elements: let elements):
            return Int(key).flatMap { elements[safe: $0]?.value } ??
                elements.first(where: { $0.label == key })?.value

        case .enum(_, _, associatedValue: .none),
             .optional,
             .value,
             .omitted:
            return nil
        }
    }

    // MARK: - Private methods

    private func firstIndex<S: StringProtocol>(in collection: [Limn], ofValueWithDescription description: S) -> Int? {

        collection.firstIndex { element in

            if case .value(description: let valueDescription) = element,
               valueDescription == description || valueDescription == "\"\(description)\"" {
                return true
            } else {
                return false
            }
        }
    }
}

extension Optional where Wrapped == Limn {

    /// Returns the `Limn` for the property identified by a given key.
    ///
    /// The keys may have different meanings depending on the type:
    /// - For classes and structs, a key identifies a property.
    /// - For collections, keys identify the index (e.g. "1").
    /// - For dictionaries, a key identifies a key from the dictionary (simple value types only).
    /// - For enums with associated values, keys identify the label of the value or its index.
    /// - For sets, a key identifies the description on value types.
    /// - For tuples, keys identify the label of a value or its index.
    /// - All other types will return `nil`.
    ///
    /// - Parameter key: The key for the desired property.
    /// - Returns: The `Limn` matching the specified key, or `nil` if it does not exist.
    public subscript(_ key: Double) -> Limn? {
        self?["\(key)"]
    }

    /// Returns the `Limn` for the property identified by a given key.
    ///
    /// The keys may have different meanings depending on the type:
    /// - For classes and structs, a key identifies a property.
    /// - For collections, keys identify the index (e.g. "1").
    /// - For dictionaries, a key identifies a key from the dictionary (simple value types only).
    /// - For enums with associated values, keys identify the label of the value or its index.
    /// - For sets, a key identifies the description on value types.
    /// - For tuples, keys identify the label of a value or its index.
    /// - All other types will return `nil`.
    ///
    /// - Parameter key: The key for the desired property.
    /// - Returns: The `Limn` matching the specified key, or `nil` if it does not exist.
    public subscript(_ key: Int) -> Limn? {
        self?["\(key)"]
    }

    /// Returns the `Limn` for the property identified by a given key.
    ///
    /// The keys may have different meanings depending on the type:
    /// - For classes and structs, a key identifies a property.
    /// - For collections, keys identify the index (e.g. "1").
    /// - For dictionaries, a key identifies a key from the dictionary (simple value types only).
    /// - For enums with associated values, keys identify the label of the value or its index.
    /// - For sets, a key identifies the description on value types.
    /// - For tuples, keys identify the label of a value or its index.
    /// - All other types will return `nil`.
    ///
    /// - Parameter key: The key for the desired property.
    /// - Returns: The `Limn` matching the specified key, or `nil` if it does not exist.
    public subscript<S: StringProtocol>(_ key: S) -> Limn? {
        self?[key]
    }
}
