extension Limn {

    /// Statistics of a `Limn`.
    public struct Stats {

        /// The total amount of diff changes entries in this `Limn` hierarchy.
        public fileprivate(set) var diffedEntriesCount = 0

        /// The total amount of filtered entries in this `Limn` hierarchy.
        public fileprivate(set) var filteredEntriesCount = 0

        /// The maximum depth of the `Limn` hierarchy.
        public fileprivate(set) var maxDepth: Int = 1

        /// Set of unique type names (from classes, structs and enums) found on the entire `Limn` hierarchy.
        public fileprivate(set) var typeNames: Set<String> = .init()

        /// The total amount of unresolved entries in this `Limn` hierarchy.
        public fileprivate(set) var unresolvedEntriesCount: Int = 0
    }

    private struct StatsContext {

        var currentDepth = 0
        var stats = Stats()
    }

    // MARK: - Public API

    /// Gathers statistics for the current `Limn`.
    ///
    /// - Returns: The ``Limn/Stats`` instance for this `Limn`.
    public func stats() -> Stats {

        var context = StatsContext()
        fillStatsRecursively(context: &context)

        return context.stats
    }

    // MARK: - Private methods

    private func fillStatsRecursively(context: inout StatsContext) {

        let initialRecursivenessLevel = context.currentDepth
        defer {
            context.stats.maxDepth = max(context.stats.maxDepth, context.currentDepth)
            context.currentDepth = initialRecursivenessLevel
        }

        switch self {
        case .class(name: let name, _, properties: let properties):
            context.currentDepth += 1
            context.stats.typeNames.insert(name)
            properties.forEach { $0.value.fillStatsRecursively(context: &context) }

        case .collection(elements: let elements):
            context.currentDepth += 1
            elements.forEach { $0.fillStatsRecursively(context: &context) }

        case .dictionary(keyValuePairs: let keyValuePairs):
            context.currentDepth += 1
            keyValuePairs.forEach { $0.value.fillStatsRecursively(context: &context) }

        case .enum(name: let name, _, associatedValue: let associatedValue):
            context.currentDepth += 1
            context.stats.typeNames.insert(name)
            associatedValue?.fillStatsRecursively(context: &context)

        case .optional(value: let value):
            value.map { $0.fillStatsRecursively(context: &context) }

        case .set(elements: let elements):
            context.currentDepth += 1
            elements.forEach { $0.fillStatsRecursively(context: &context) }

        case .struct where isDiffStruct:
            context.stats.diffedEntriesCount += 1
            Diff(from: self)?.update?.fillStatsRecursively(context: &context)

        case .struct(name: let name, properties: let properties):
            context.currentDepth += 1
            context.stats.typeNames.insert(name)
            properties.forEach { $0.value.fillStatsRecursively(context: &context) }

        case .tuple(elements: let elements):
            context.currentDepth += 1
            elements.forEach { $0.value.fillStatsRecursively(context: &context) }

        case .value:
            context.currentDepth += 1

        case .omitted(reason: .filtered):
            context.stats.filteredEntriesCount += 1

        case .omitted(reason: .maxDepthExceeded),
             .omitted(reason: .referenceCycleDetected):
            break

        case .omitted(reason: .unresolved):
            context.stats.unresolvedEntriesCount += 1
        }
    }
}
