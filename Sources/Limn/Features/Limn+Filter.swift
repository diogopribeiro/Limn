import Foundation

extension Limn {

    // MARK: - Types

    private struct FilterContext {

        var currentMatchDepth: Int = 0
        let include: (Limn) -> Bool
        let matchDepth: Int

        init(currentMatchDepth: Int = 0, matchDepth: Int, include: @escaping (Limn) -> Bool) {

            assert(matchDepth >= 0, "'matchDepth' must be a value higher or equal to 0")

            self.currentMatchDepth = currentMatchDepth
            self.include = include
            self.matchDepth = max(0, matchDepth)
        }

        var decrementingCurrentMatchDepth: Self {
            Self(currentMatchDepth: max(0, currentMatchDepth - 1), matchDepth: matchDepth, include: include)
        }

        var incrementingCurrentMatchDepth: Self {
            Self(currentMatchDepth: currentMatchDepth + 1, matchDepth: matchDepth, include: include)
        }

        var maximizingCurrentMatchDepth: Self {
            Self(currentMatchDepth: matchDepth, matchDepth: matchDepth, include: include)
        }
    }

    // MARK: - Public API

    /// Filters this `Limn` hierarchy by instance display style.
    ///
    /// - Parameters:
    ///   - displayStyle: The instance display style to filter by.
    ///   - matchDepth: The maximum depth to which child values of matches will remain unfiltered (even if they do not
    ///     match the original filter criteria). The default value is `0`.
    /// - Returns: The original `Limn` instance with filtered values replaced by `.omitted(reason: .filtered)`.
    public func filtered(displayStyle: DisplayStyle, matchDepth: Int = 0) -> Limn {

        filteredRecursively(context: .init(matchDepth: matchDepth) { limn in

            switch (limn, displayStyle) {
            case (.class, .class),
                 (.collection, .collection),
                 (.dictionary, .dictionary),
                 (.enum, .enum),
                 (.enum, .value),
                 (.optional, .optional),
                 (.set, .set),
                 (.struct, .struct),
                 (.tuple, .tuple),
                 (.value, .value):
                return true

            default:
                return false
            }
        })
    }

    /// Filters this `Limn` hierarchy by value description.
    ///
    /// - Parameters:
    ///   - value: The value description to filter by. You can use wildcard (\*) placeholders on this property.
    ///   - matchDepth: The maximum depth to which child values of matches will remain unfiltered (even if they do not
    ///     match the original filter criteria). The default value is `0`.
    /// - Returns: The original `Limn` instance with filtered values replaced by `.omitted(reason: .filtered)`.
    public func filtered(value: String, matchDepth: Int = 0) -> Limn {

        filteredRecursively(context: .init(matchDepth: matchDepth) { limn in

            switch limn {
            case .enum(_, caseName: let caseName, _):
                return evaluate(filterQuery: value, matchesValue: caseName) ||
                    evaluate(filterQuery: value, matchesValue: ".\(caseName)")

            case .value(description: let description):
                return evaluate(filterQuery: value, matchesValue: description)

            case .class,
                 .collection,
                 .dictionary,
                 .optional,
                 .set,
                 .struct,
                 .tuple,
                 .omitted:
                return false
            }
        })
    }

    // MARK: - Private methods

    private func evaluate(filterQuery query: String, matchesValue value: String) -> Bool {
        NSPredicate(format: "self LIKE %@", query).evaluate(with: value)
    }

    private func filteredRecursively(context: FilterContext) -> Limn {

        switch self {
        case .class:
            return filterClassRecursively(context: context)

        case .collection:
            return filterCollectionRecursively(context: context)

        case .dictionary:
            return filterDictionaryRecursively(context: context)

        case .enum:
            return filterEnumRecursively(context: context)

        case .optional:
            return filterOptionalRecursively(context: context)

        case .set:
            return filterSetRecursively(context: context)

        case .struct:
            return filterStructRecursively(context: context)
            
        case .tuple:
            return filterTupleRecursively(context: context)

        case .value:
            return filterValueRecursively(context: context)

        case .omitted:
            return filterOmittedRecursively(context: context)
        }
    }

    private func filterClassRecursively(context: FilterContext) -> Limn {

        guard case .class(name: let name, address: let address, properties: let properties) = self else {
            assertionFailure()
            return .omitted(reason: .filtered)
        }

        let includeLimn = context.include(self)
        let updatedContext = includeLimn ? context.maximizingCurrentMatchDepth : context.decrementingCurrentMatchDepth
        var foundUnfilteredProperty = false
        let filteredProperties = properties.map { property -> LabeledLimn in
            let filteredPropertyValue = property.value.filteredRecursively(context: updatedContext)
            foundUnfilteredProperty = foundUnfilteredProperty || !filteredPropertyValue.isOmitted
            return .init(property.label, filteredPropertyValue)
        }

        if includeLimn || context.currentMatchDepth > 0 || foundUnfilteredProperty {
            return .class(name: name, address: address, properties: filteredProperties)
        } else {
            return .omitted(reason: .filtered)
        }
    }

    private func filterCollectionRecursively(context: FilterContext) -> Limn {

        guard case .collection(elements: let elements) = self else {
            assertionFailure()
            return .omitted(reason: .filtered)
        }

        let includeLimn = context.include(self)
        let updatedContext = includeLimn ? context.maximizingCurrentMatchDepth : context.decrementingCurrentMatchDepth
        var foundUnfilteredElement = false
        let filteredElements = elements.map { element -> Limn in
            let filteredElement = element.filteredRecursively(context: updatedContext)
            foundUnfilteredElement = foundUnfilteredElement || !filteredElement.isOmitted
            return filteredElement
        }

        if includeLimn || context.currentMatchDepth > 0 || foundUnfilteredElement {
            return .collection(elements: filteredElements)
        } else {
            return .omitted(reason: .filtered)
        }
    }

    private func filterDictionaryRecursively(context: FilterContext) -> Limn {

        guard case .dictionary(keyValuePairs: let keyValuePairs) = self else {
            assertionFailure()
            return .omitted(reason: .filtered)
        }

        let includeLimn = context.include(self)
        let updatedContext = includeLimn ? context.maximizingCurrentMatchDepth : context.decrementingCurrentMatchDepth
        var foundUnfilteredKeyValuePair = false
        let filteredKeyValuePairs = keyValuePairs.compactMap { element -> KeyedLimn? in
            let filteredKey = element.key.filteredRecursively(context: updatedContext)
            let filteredValue = element.value.filteredRecursively(context: updatedContext)
            if filteredKey.isOmitted && filteredValue.isOmitted {
                return .init(.omitted(reason: .filtered), .omitted(reason: .filtered))
            } else {
                foundUnfilteredKeyValuePair = true
                return .init(
                    filteredKey.isOmitted ? element.key : filteredKey,
                    filteredValue.isOmitted ? element.value : filteredValue
                )
            }
        }

        if includeLimn || context.currentMatchDepth > 0 || foundUnfilteredKeyValuePair {
            return .dictionary(keyValuePairs: filteredKeyValuePairs)
        } else {
            return .omitted(reason: .filtered)
        }
    }

    private func filterEnumRecursively(context: FilterContext) -> Limn {

        guard case .enum(name: let name, caseName: let caseName, associatedValue: let associatedValue) = self else {
            assertionFailure()
            return .omitted(reason: .filtered)
        }

        let includeLimn = context.include(self)
        let updatedContext = includeLimn ? context.maximizingCurrentMatchDepth : context.decrementingCurrentMatchDepth
        let filteredAssociatedValue = associatedValue?.filteredRecursively(context: updatedContext)

        if includeLimn || context.currentMatchDepth > 0 || (filteredAssociatedValue?.isOmitted == false) {
            return .enum(name: name, caseName: caseName, associatedValue: filteredAssociatedValue)
        } else {
            return .omitted(reason: .filtered)
        }
    }

    private func filterOptionalRecursively(context: FilterContext) -> Limn {

        guard case .optional(value: let value) = self else {
            assertionFailure()
            return .omitted(reason: .filtered)
        }

        let includeLimn = context.include(self)
        guard let value = value else {
            return includeLimn ? self : .omitted(reason: .filtered)
        }

        var updatedContext = includeLimn ? context.maximizingCurrentMatchDepth : context
        let filteredValue = value.filteredRecursively(context: updatedContext)
        if includeLimn && filteredValue.isOmitted {
            updatedContext = context.maximizingCurrentMatchDepth.incrementingCurrentMatchDepth
            return .optional(value: value.filteredRecursively(context: updatedContext))
        } else if !includeLimn && context.currentMatchDepth > 0 && filteredValue.isOmitted {
            updatedContext = context.incrementingCurrentMatchDepth
            return .optional(value: value.filteredRecursively(context: updatedContext))
        } else if includeLimn || !filteredValue.isOmitted {
            return .optional(value: filteredValue)
        } else {
            return .omitted(reason: .filtered)
        }
    }

    private func filterSetRecursively(context: FilterContext) -> Limn {

        guard case .set(elements: let elements) = self else {
            assertionFailure()
            return .omitted(reason: .filtered)
        }

        let includeLimn = context.include(self)
        let updatedContext = includeLimn ? context.maximizingCurrentMatchDepth : context.decrementingCurrentMatchDepth
        var foundUnfilteredElement = false
        let filteredElements = elements.map { element -> Limn in
            let filteredElement = element.filteredRecursively(context: updatedContext)
            foundUnfilteredElement = foundUnfilteredElement || !filteredElement.isOmitted
            return filteredElement
        }

        if includeLimn || context.currentMatchDepth > 0 || foundUnfilteredElement {
            return .set(elements: filteredElements)
        } else {
            return .omitted(reason: .filtered)
        }
    }

    private func filterStructRecursively(context: FilterContext) -> Limn {

        guard case .struct(name: let name, properties: let properties) = self else {
            assertionFailure()
            return .omitted(reason: .filtered)
        }

        let includeLimn = context.include(self)
        let updatedContext = includeLimn ? context.maximizingCurrentMatchDepth : context.decrementingCurrentMatchDepth
        var foundUnfilteredProperty = false
        let filteredProperties = properties.map { property -> LabeledLimn in
            let filteredPropertyValue = property.value.filteredRecursively(context: updatedContext)
            foundUnfilteredProperty = foundUnfilteredProperty || !filteredPropertyValue.isOmitted
            return .init(property.label, filteredPropertyValue)
        }

        if includeLimn || context.currentMatchDepth > 0 || foundUnfilteredProperty {
            return .struct(name: name, properties: filteredProperties)
        } else {
            return .omitted(reason: .filtered)
        }
    }

    private func filterTupleRecursively(context: FilterContext) -> Limn {

        guard case .tuple(elements: let elements) = self else {
            assertionFailure()
            return .omitted(reason: .filtered)
        }

        let includeLimn = context.include(self)
        let updatedContext = includeLimn ? context.maximizingCurrentMatchDepth : context.decrementingCurrentMatchDepth
        var foundUnfilteredElement = false
        let filteredElements = elements.compactMap { element -> LabeledLimn in
            let filteredElementValue = element.value.filteredRecursively(context: updatedContext)
            foundUnfilteredElement = foundUnfilteredElement || !filteredElementValue.isOmitted
            return .init(element.label, filteredElementValue)
        }

        if includeLimn || context.currentMatchDepth > 0 || foundUnfilteredElement {
            return .tuple(elements: filteredElements)
        } else {
            return .omitted(reason: .filtered)
        }
    }

    private func filterValueRecursively(context: FilterContext) -> Limn {

        guard case .value = self else {
            assertionFailure()
            return .omitted(reason: .filtered)
        }

        if context.include(self) || context.currentMatchDepth > 0 {
            return self
        } else {
            return .omitted(reason: .filtered)
        }
    }

    private func filterOmittedRecursively(context: FilterContext) -> Limn {

        guard case .omitted = self else {
            assertionFailure()
            return .omitted(reason: .filtered)
        }

        if context.include(self) || context.currentMatchDepth > 0 {
            return self
        } else {
            return .omitted(reason: .filtered)
        }
    }
}
