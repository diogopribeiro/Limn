extension Limn {

    // MARK: - Types

    /// Represents a "before" and "after" divergence point in a `Limn` hierarchy.
    struct Diff {

        let original: Limn? // nil == value was added
        let update: Limn? // nil == value was removed

        init(original: Limn? = nil, update: Limn? = nil) {

            self.original = original
            self.update = update
        }

        init?(from limnValue: Limn) {

            guard case .struct(String(reflecting: Self.self), let properties) = limnValue else {
                assertionFailure()
                return nil
            }

            original = properties.first(where: { $0.label == "original" })?.value
            update = properties.first(where: { $0.label == "update" })?.value
        }

        var limnValue: Limn {

            // A `Limn` for this struct will be created manually as it will store other existing Limns. Using the
            // default `Limn(of:)` initializer would create a Limn describing another Limn. It's also not possible to
            // store `nil` properties in a `Limn` (by design), so we'll manually omit `nil` values instead.

            let name = typeName(of: self)
            var properties = [LabeledLimn]()
            if let original = original { properties.append(LabeledLimn("original", original)) }
            if let update = update { properties.append(LabeledLimn("update", update)) }

            return .struct(name: name, properties: properties)
        }
    }
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
extension Limn {

    // MARK: - Public API

    /// Determines if this `Limn` contains diffing information.
    public var containsDiff: Bool {

        switch self {
        case .class(_, _, properties: let properties),
             .tuple(elements: let properties):
            return properties.contains(where: \.value.containsDiff)

        case .collection(elements: let elements),
             .set(elements: let elements):
            return elements.contains(where: \.containsDiff)

        case .dictionary(keyValuePairs: let keyValuePairs):
            return keyValuePairs.contains { $0.value.containsDiff }

        case .enum(_, _, associatedValue: let associatedValue):
            return associatedValue?.containsDiff ?? false

        case .optional(value: let value):
            return value?.containsDiff ?? false

        case .struct(_, properties: let properties):
            return isDiffStruct || properties.contains(where: \.value.containsDiff)

        case .value,
             .omitted:
            return false
        }
    }

    /// Creates a `Limn` with the contents of and differences between two values of a given type.
    ///
    /// - Parameters:
    ///   - original: The original value.
    ///   - update: The updated value to compare to.
    ///   - maxDepth: The maximum level of recursion to use when resolving the `Limn` of child members of the passed
    ///     instance. Child values beyond this level will always be equal to `.omitted(reason: .maxDepthExceeded)`. The
    ///     default value for this property is `Int.max`.     
    /// - Returns: A `Limn` with the contents of and differences between the two values.
    public static func diff<T>(from original: T, to update: T, maxDepth: Int = .max) -> Limn {

        let originalLimn = Limn(of: original, maxDepth: maxDepth)
        let updateLimn = Limn(of: update, maxDepth: maxDepth)

        return originalLimn.diffed(to: updateLimn)
    }

    /// Inserts diffing information to this `Limn` based on the differences to another value.
    ///
    /// If the calling `Limn` contains diffing information, it will be reverted (undiffed) to the original value before
    /// performing the diff. If the passed value is a `Limn` with diffing information, it will be reverted (undiffed) to
    /// the updated value before performing the diff. If you wish for a different behavior, use the method
    /// `undiffed(to:)` to revert the changes on either `Limn` value prior to passing it to this method.
    ///
    /// - Parameter update: The updated `Limn` to compare to.
    /// - Returns: The current `Limn` with diffing information added to it, or `self` if no changes were found.
    public func diffed<T>(to update: T) -> Limn {

        let original = containsDiff ? undiffed(to: .original) : self
        let updateLimn: Limn = update as? Limn ?? Limn(of: update)
        let update = updateLimn.containsDiff ? updateLimn.undiffed(to: .update) : updateLimn

        if let original = original, let update = update {
            return original.diffedRecursively(to: update)
        } else if let original = original {
            return Diff(original: original).limnValue
        } else if let update = update {
            return Diff(update: update).limnValue
        } else {
            assertionFailure()
            return self
        }
    }

    // MARK: - Private methods

    private func diffedRecursively(to update: Self) -> Limn {

        switch self {
        case .class:
            return diffedClassRecursively(to: update)

        case .collection:
            return diffedCollectionRecursively(to: update)

        case .dictionary:
            return diffedDictionaryRecursively(to: update)

        case .enum:
            return diffedEnumRecursively(to: update)

        case .optional:
            return diffedOptionalRecursively(to: update)

        case .set:
            return diffedSetRecursively(to: update)

        case .struct:
            return diffedStructRecursively(to: update)

        case .tuple:
            return diffedTupleRecursively(to: update)

        case .value:
            return diffedValueRecursively(to: update)

        case .omitted:
            return diffedOmittedRecursively(to: update)
        }
    }

    private func diffedClassRecursively(to update: Limn) -> Limn {

        guard
            case .class(name: let oldName, address: let oldAddress, properties: let oldProperties) = self,
            case .class(name: let newName, address: let newAddress, properties: let newProperties) = update
        else {
            return Diff(original: self, update: update).limnValue
        }

        let diffedProperties = diffedUnorderedLabeledLimns(from: oldProperties, to: newProperties)
        let update = Limn.class(name: newName, address: newAddress, properties: diffedProperties)
        if oldName != newName || oldAddress != newAddress {
            let original = Limn.class(name: oldName, address: oldAddress, properties: diffedProperties)
            return Diff(original: original, update: update).limnValue
        } else {
            return update
        }
    }

    private func diffedCollectionRecursively(to update: Limn) -> Limn {
        
        guard
            case .collection(elements: let oldElements) = self,
            case .collection(elements: let newElements) = update
        else {
            return Diff(original: self, update: update).limnValue
        }
        
        let diffedElements = diffedCollectionElements(from: oldElements, to: newElements)
        return .collection(elements: diffedElements)
    }

    private func diffedDictionaryRecursively(to update: Limn) -> Limn {

        guard
            case .dictionary(keyValuePairs: let oldKeyValuePairs) = self,
            case .dictionary(keyValuePairs: let newKeyValuePairs) = update
        else {
            return Diff(original: self, update: update).limnValue
        }

        let diffedKeyValuePairs = diffedKeyedLimns(from: oldKeyValuePairs, to: newKeyValuePairs)
        return .dictionary(keyValuePairs: diffedKeyValuePairs)
    }

    private func diffedEnumRecursively(to update: Limn) -> Limn {

        guard
            case .enum(name: let oldName, caseName: let oldCaseName, associatedValue: let oldAssociatedValue) = self,
            case .enum(name: let newName, caseName: let newCaseName, associatedValue: let newAssociatedValue) = update
        else {
            return Diff(original: self, update: update).limnValue
        }

        if oldName != newName || oldCaseName != newCaseName {

            let update = Limn.enum(name: newName, caseName: newCaseName, associatedValue: newAssociatedValue)
            return Diff(original: self, update: update).limnValue

        } else {

            let diffedAssociatedValue: Limn?
            if (oldAssociatedValue == nil) == (newAssociatedValue == nil) {
                diffedAssociatedValue = newAssociatedValue.flatMap { oldAssociatedValue?.diffedRecursively(to: $0) }
            } else if oldAssociatedValue == nil {
                diffedAssociatedValue = Diff(original: .optional(value: nil), update: newAssociatedValue!).limnValue
            } else {
                diffedAssociatedValue = Diff(original: oldAssociatedValue!, update: .optional(value: nil)).limnValue
            }
            return .enum(name: oldName, caseName: oldCaseName, associatedValue: diffedAssociatedValue)
        }
    }

    private func diffedOptionalRecursively(to update: Limn) -> Limn {

        guard
            case .optional(value: let oldValue) = self,
            case .optional(value: let newValue) = update
        else {
            return Diff(original: self, update: update).limnValue
        }

        if let oldValue = oldValue, let newValue = newValue {
            let diffedValue = oldValue.diffedRecursively(to: newValue)
            return .optional(value: diffedValue)
        } else if (oldValue == nil) != (newValue == nil) {
            let update = Limn.optional(value: newValue)
            return Diff(original: self, update: update).limnValue
        } else {
            return self
        }
    }

    private func diffedSetRecursively(to update: Limn) -> Limn {

        guard
            case .set(elements: let oldElements) = self,
            case .set(elements: let newElements) = update
        else {
            return Diff(original: self, update: update).limnValue
        }

        let diffedElements = diffedSetElements(from: oldElements, to: newElements)
        return .set(elements: diffedElements)
    }

    private func diffedStructRecursively(to update: Limn) -> Limn {

        guard
            case .struct(name: let oldName, properties: let oldProperties) = self,
            case .struct(name: let newName, properties: let newProperties) = update
        else {
            return Diff(original: self, update: update).limnValue
        }

        let diffedProperties = diffedUnorderedLabeledLimns(from: oldProperties, to: newProperties)
        if oldName != newName {
            let original = Limn.struct(name: oldName, properties: diffedProperties)
            let update = Limn.struct(name: newName, properties: diffedProperties)
            return Diff(original: original, update: update).limnValue
        } else {
            return .struct(name: oldName, properties: diffedProperties)
        }
    }

    private func diffedTupleRecursively(to update: Limn) -> Limn {

        guard
            case .tuple(elements: let oldElements) = self,
            case .tuple(elements: let newElements) = update
        else {
            return Diff(original: self, update: update).limnValue
        }

        if oldElements.map(\.label) != newElements.map(\.label) {
            return Diff(original: self, update: update).limnValue
        } else {
            let diffedElements = zip(oldElements, newElements).map { (lhs, rhs) -> LabeledLimn in
                let diffedValue = lhs.value.diffedRecursively(to: rhs.value)
                return .init(lhs.label, diffedValue)
            }
            return .tuple(elements: diffedElements)
        }
    }

    private func diffedValueRecursively(to update: Limn) -> Limn {

        guard
            case .value(description: let oldDescription) = self,
            case .value(description: let newDescription) = update
        else {
            return Diff(original: self, update: update).limnValue
        }

        if oldDescription != newDescription {
            let update = Limn.value(description: newDescription)
            return Diff(original: self, update: update).limnValue
        } else {
            return self
        }
    }

    private func diffedOmittedRecursively(to update: Limn) -> Limn {

        guard
            case .omitted(reason: let oldReason) = self,
            case .omitted(reason: let newReason) = update
        else {
            return Diff(original: self, update: update).limnValue
        }

        if oldReason != newReason {
            let update = Limn.omitted(reason: newReason)
            return Diff(original: self, update: update).limnValue
        } else {
            return self
        }
    }

    // MARK: Diffing of child collections and pairs

    private func diffedCollectionElements(from oldElements: [Limn], to newElements: [Limn]) -> [Limn] {

        let diff = newElements.difference(from: oldElements)

        var result = [Limn]()
        var oldElementsOffset = 0
        var newElementsOffset = 0

        while oldElementsOffset < oldElements.count || newElementsOffset < newElements.count {

            let isRemoval = diff.removals.contains { $0.offset == oldElementsOffset }
            let isInsertion = diff.insertions.contains { $0.offset == newElementsOffset }

            switch (isRemoval, isInsertion) {
            case (false, false):
                let oldElement = oldElements[oldElementsOffset]
                let newElement = newElements[newElementsOffset]
                result.append(oldElement.diffedRecursively(to: newElement))
                oldElementsOffset += 1
                newElementsOffset += 1

            case (false, true):
                let newElement = newElements[newElementsOffset]
                result.append(Diff(update: newElement).limnValue)
                newElementsOffset += 1

            case (true, false):
                let oldElement = oldElements[oldElementsOffset]
                result.append(Diff(original: oldElement).limnValue)
                oldElementsOffset += 1

            case (true, true):
                let oldElement = oldElements[oldElementsOffset]
                let newElement = newElements[newElementsOffset]
                result.append(oldElement.diffedRecursively(to: newElement))
                oldElementsOffset += 1
                newElementsOffset += 1
            }
        }

        return result
    }

    private func diffedSetElements(from oldElements: [Limn], to newElements: [Limn]) -> [Limn] {

        let oldElementsSet = Set(oldElements.filter { !$0.isOmitted })
        let newElementsSet = Set(newElements.filter { !$0.isOmitted })

        var result = oldElementsSet.map { oldElement -> Limn in
            if newElementsSet.contains(oldElement) {
                return oldElement
            } else {
                return Diff(original: oldElement).limnValue
            }
        }

        let insertedElements = newElementsSet.subtracting(oldElementsSet)
            .map { Diff(update: $0).limnValue }
        result += insertedElements

        return result
    }

    private func diffedUnorderedLabeledLimns(
        from oldPairs: [LabeledLimn],
        to newPairs: [LabeledLimn]
    ) -> [LabeledLimn] {

        let oldPairs = oldPairs.filter { !$0.value.isOmitted }
        let newPairs = newPairs.filter { !$0.value.isOmitted }

        let oldPairsDictionary = Dictionary(uniqueKeysWithValues: oldPairs.map({ ($0.label, $0) }))
        let newPairsDictionary = Dictionary(uniqueKeysWithValues: newPairs.map({ ($0.label, $0) }))

        var result = oldPairs.map { pair -> LabeledLimn in
            if let newPair = newPairsDictionary[pair.label] {
                return .init(pair.label, pair.value.diffedRecursively(to: newPair.value))
            } else {
                return .init(pair.label, Diff(original: pair.value).limnValue)
            }
        }

        let insertedPairs = Set(newPairsDictionary.keys).subtracting(Set(oldPairsDictionary.keys))
        insertedPairs.forEach { removedPairLabel in
            result.append(newPairsDictionary[removedPairLabel]!)
        }

        return result
    }

    private func diffedKeyedLimns(from oldPairs: [KeyedLimn], to newPairs: [KeyedLimn]) -> [KeyedLimn] {

        let oldPairs = oldPairs.filter { !$0.value.isOmitted }
        let newPairs = newPairs.filter { !$0.value.isOmitted }

        let oldPairsDictionary = Dictionary(uniqueKeysWithValues: oldPairs.map({ ($0.key, $0) }))
        let newPairsDictionary = Dictionary(uniqueKeysWithValues: newPairs.map({ ($0.key, $0) }))

        var result = oldPairs.map { pair -> KeyedLimn in
            if let newPair = newPairsDictionary[pair.key] {
                let diffedKey = pair.key.diffedRecursively(to: newPair.key)
                let diffedValue = pair.value.diffedRecursively(to: newPair.value)
                return .init(diffedKey, diffedValue)
            } else {
                return .init(Diff(original: pair.key).limnValue, Diff(original: pair.value).limnValue)
            }
        }

        let insertedPairKeys = Set(newPairsDictionary.keys).subtracting(Set(oldPairsDictionary.keys))
        insertedPairKeys.forEach { insertedPairKey in
            let insertedPair = newPairsDictionary[insertedPairKey]
            result.append(KeyedLimn(
                Diff(original: nil, update: insertedPair?.key).limnValue,
                Diff(original: nil, update: insertedPair?.value).limnValue
            ))
        }

        return result
    }
}
