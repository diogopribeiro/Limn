extension Limn {

    // MARK: - Types

    public struct DumpSymbols {

        public var classPrefix      = "%@("
        public var classSuffix      = ") @ %@"
        public var collectionPrefix = "["
        public var collectionIndex  = ".%d"
        public var collectionSuffix = "]"
        public var dictionaryPrefix = "["
        public var dictionaryEmpty  = "[:]"
        public var dictionarySuffix = "]"
        public var `enum`           = "%2$@.%1$@"
        public var enumWithAVPrefix = "%2$@.%1$@("
        public var enumWithAVSuffix = ")"
        public var setPrefix        = "Set(["
        public var setSuffix        = "])"
        public var structPrefix     = "%@("
        public var structSuffix     = ")"
        public var tuplePrefix      = "("
        public var tupleSuffix      = ")"

        public var diffInsertedLinePrefix  = "+ "
        public var diffRemovedLinePrefix   = "- "
        public var diffUnchangedLinePrefix = "  "
        public var nameValueSeparator      = ": "
        public var elementSeparator        = ", "
        public var indentationCharacters   = "    "
        public var nilValue                = "nil"
        public var omittedUnresolved       = "?"
        public var omittedMaxDepthExceeded = "…"
        public var omittedRefCycleDetected = "… (skipped due to reference cycle)"
        public var propertyLabel           = "%@"
        public var summaryEntryFiltered    = "%d filtered"
        public var summaryEntrySkipped     = "%d more"
        public var summaryEntryUnchanged   = "%d unchanged"
        public var summarySingleEntry      = "… (%@)"
        public var summaryDualEntry        = "… (%@ with %@)"

        public static var `default` = Self()
    }

    public struct DumpFormat {

        public var collectionIndexMinItems: Int = 10
        public var maxItems: Int = 32
        public var maxLineWidth: Int = 0
        public var symbols: DumpSymbols = .default
        public var typeNameComponents: OptionalTypeNameComponents = .genericTypeParameterNames

        /// The output format to use.
        ///
        /// - Parameters:
        ///   - maxItems: The maximum number of elements for which to write the full contents. The default is `Int.max`.
        ///   - maxLineWidth: The preferred maximum line width to which elements will be justified to. Elements that fit
        ///     entirely withing this width will be printed in the same line, otherwise they'll be split into multiple
        ///     lines.
        ///   - collectionIndexMinItems: The minimum collection size from which an index will be prepended to each
        ///     element. The default value is `Int.max`.
        ///   - typeNameComponents: The components to include when printing type names. The default value is
        ///     `[.genericTypeParameterNames]`.
        ///   - symbols: The list of symbols to use when writing items to the output. The default is
        ///     `DumpSymbols.default`.
        public init(
            maxItems: Int = .max,
            maxLineWidth: Int = 0,
            collectionIndexMinItems: Int = .max,
            typeNameComponents: OptionalTypeNameComponents = .genericTypeParameterNames,
            symbols: Limn.DumpSymbols = .default
        ) {

            self.maxItems = maxItems
            self.maxLineWidth = maxLineWidth
            self.collectionIndexMinItems = collectionIndexMinItems
            self.typeNameComponents = typeNameComponents
            self.symbols = symbols
        }

        public static var `default` = Self()
        public static func json(minified: Bool = false) -> Self {
            Self.init (
                maxItems: .max,
                maxLineWidth: minified ? .max : 0,
                collectionIndexMinItems: .max,
                typeNameComponents: [],
                symbols: .init(
                    classPrefix: "{",
                    classSuffix: "}",
                    collectionIndex: "(%2$d)",
                    enum: "\"%@\"",
                    enumWithAVPrefix: minified ? "{\"%@\":{" : "{ \"%@\": {",
                    enumWithAVSuffix: "}}",
                    setPrefix: "[",
                    setSuffix: "]",
                    structPrefix: "{",
                    structSuffix: "}",
                    tuplePrefix: "{",
                    tupleSuffix: "}",
                    nameValueSeparator: minified ? ":" : ": ",
                    elementSeparator: minified ? "," : ", ",
                    nilValue: "null",
                    propertyLabel: "\"%@\""
                )
            )
        }
    }

    /// An intermediate representation of a `Limn` more suitable for text-based manipulation and conversion.
    private indirect enum Token: Hashable {

        case diff(Self?)
        case filtered

        case group(prefix: String, subtokens: [Self], suffix: String)
        case pair(first: Self?, separator: String, second: Self)
        case value(String)

        var containsDiff: Bool {

            switch self {
            case .diff:
                return true

            case .filtered,
                 .value:
                return false

            case .group(_, subtokens: let subtokens, _):
                return subtokens.contains(where: \.containsDiff)

            case .pair(first: let first, _, second: let second):
                return (first?.containsDiff ?? false) || second.containsDiff
            }
        }

        func fits(width availableWidth: Int, format: DumpFormat) -> Bool {

            switch self {
            case .diff(.some(let diff)):
                return diff.fits(width: availableWidth, format: format)

            case .group(prefix: let prefix, subtokens: let subtokens, suffix: let suffix):
                var accumulated = prefix.count + suffix.count
                guard accumulated <= availableWidth else { return false }
                for (index, subtoken) in subtokens.enumerated() {
                    accumulated += subtoken.width(format: format) +
                        (index < subtokens.count - 1 ? format.symbols.elementSeparator.count : 0)
                    guard accumulated <= availableWidth else { return false }
                }
                return true

            case .diff(.none),
                 .filtered,
                 .pair,
                 .value:
                return width(format: format) < availableWidth
            }
        }

        var isDeleted: Bool {

            switch self {
            case .diff(let value):
                return value == nil

            case .filtered,
                 .group,
                 .value:
                return false

            case .pair(_, _, second: let second):
                return second.isDeleted
            }
        }

        var isFiltered: Bool {

            switch self {
            case .diff(let value):
                return value?.isFiltered ?? false

            case .filtered:
                return true

            case .group,
                 .value:
                return false

            case .pair(_, _, second: let second):
                return second.isFiltered
            }
        }

        func width(format: DumpFormat) -> Int {

            switch self {
            case .diff(let value):
                return value?.width(format: format) ?? 0

            case .filtered:
                return 0

            case .group(prefix: let prefix, subtokens: let subtokens, suffix: let suffix):
                return prefix.count + subtokens.reduce(into: 0, { $0 += $1.width(format: format) }) +
                    (max(0, subtokens.count - 1) * format.symbols.elementSeparator.count) + suffix.count

            case .pair(first: let first, separator: let separator, second: let second):
                return (first.map({ $0.width(format: format) }) ?? 0) + separator.count +
                    second.width(format: format)

            case .value(let value):
                return value.count
            }
        }
    }

    // MARK: - Public API

    /// Prints the contents of this `Limn` to the standard output.
    ///
    /// - Parameters:
    ///   - format: The format to use when printing all elements.
    ///   - terminator: The string to print after all items have been printed. The default is a newline ("\n").
    public func dump(format: DumpFormat = .default, terminator: String = "\n") {

        var output = FileHandleTextOutputStream(fileHandle: .standardOutput)
        dump(format: format, to: &output)
    }

    /// Outputs the contents of this `Limn` to a `TextOutputStream` using the given format.
    ///
    /// - Parameters:
    ///   - format: The format to use when printing all elements.
    ///   - stream: The `TextOutputStream` to output the contents to.
    ///   - terminator: The string to print after all items have been printed. The default is a newline ("\n").
    public func dump<T: TextOutputStream>(
        format: DumpFormat = .default,
        to stream: inout T,
        terminator: String = "\n"
    ) {

        if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *), containsDiff {

            var originalValueToken = tokenize(format: format, undiffDirection: .original, isRootLevel: true)
            var updatedValueToken = tokenize(format: format, undiffDirection: .update, isRootLevel: true)
            originalValueToken = process(originalValueToken, format: format, isRootLevel: true)
            updatedValueToken = process(updatedValueToken, format: format, isRootLevel: true)

            printDiff(originalValueToken, updatedValueToken, to: &stream, format: format, terminator: terminator)

        } else {

            var token = tokenize(format: format, undiffDirection: .original, isRootLevel: true)
            token = process(token, format: format, isRootLevel: true)

            print(token, to: &stream, format: format, terminator: terminator)
        }
    }

    /// Outputs the contents of this `Limn` into a `String` using the given format.
    ///
    /// - Parameter format: The format to use when printing all elements.
    public func stringDump(format: DumpFormat = .default) -> String {

        var output = ""
        dump(format: format, to: &output, terminator: "")

        return output
    }

    // MARK: - Private methods

    private func tokenize(format: DumpFormat, undiffDirection: UndiffDirection, isRootLevel: Bool = false) -> Token {

        func tokenizePairs(_ labeledLimns: [LabeledLimn]) -> [Token] {
            labeledLimns.map { labeledLimn -> Token in
                let first = Token.value(String(format: format.symbols.propertyLabel, labeledLimn.label))
                let second = labeledLimn.value.tokenize(format: format, undiffDirection: undiffDirection)
                return Token.pair(first: first, separator: format.symbols.nameValueSeparator, second: second)
            }
        }

        switch self {
        case .class(name: let name, address: let address, properties: let properties):
            let formattedName = Self.format(typeName: name, including: format.typeNameComponents)
            let prefix = String(format: format.symbols.classPrefix, formattedName)
            let suffix = String(format: format.symbols.classSuffix, address)
            if properties == [.omitted(reason: .maxDepthExceeded)] {
                return .value(prefix + format.symbols.omittedMaxDepthExceeded + suffix)
            } else if properties == [.omitted(reason: .referenceCycleDetected)] {
                return .value(prefix + format.symbols.omittedRefCycleDetected + suffix)
            } else {
                let subtokens = tokenizePairs(properties)
                return .group(prefix: prefix, subtokens: subtokens, suffix: suffix)
            }

        case .collection(elements: let elements):
            let prefix = format.symbols.collectionPrefix
            let suffix = format.symbols.collectionSuffix
            if elements == [.omitted(reason: .maxDepthExceeded)] {
                return .value(prefix + format.symbols.omittedMaxDepthExceeded + suffix)
            } else if elements.count <= format.collectionIndexMinItems {
                let subtokens = elements.map { $0.tokenize(format: format, undiffDirection: undiffDirection) }
                return .group(prefix: prefix, subtokens: subtokens, suffix: suffix)
            } else {
                var elementIndex = 0
                let subtokens = elements.map { element -> Token in
                    let first = Token.value(String(format: format.symbols.collectionIndex, elementIndex))
                    let second = element.tokenize(format: format, undiffDirection: undiffDirection)
                    if second.isDeleted {
                        return Token.pair(first: nil, separator: "", second: second)
                    } else {
                        elementIndex += 1
                        return Token.pair(first: first, separator: format.symbols.nameValueSeparator, second: second)
                    }
                }
                return .group(prefix: prefix, subtokens: subtokens, suffix: suffix)
            }

        case .dictionary(keyValuePairs: []):
            return .value(format.symbols.dictionaryEmpty)

        case .dictionary(keyValuePairs: let keyValuePairs):
            let prefix = format.symbols.dictionaryPrefix
            let suffix = format.symbols.dictionarySuffix
            if keyValuePairs == [.omitted(reason: .maxDepthExceeded)] {
                let maxDepthSymbol = format.symbols.omittedMaxDepthExceeded
                return .value(prefix + maxDepthSymbol + format.symbols.nameValueSeparator + maxDepthSymbol + suffix)
            } else {
                let subtokens = keyValuePairs.map { keyValuePair -> Token in
                    let first = keyValuePair.key.tokenize(format: format, undiffDirection: undiffDirection)
                    let second = keyValuePair.value.tokenize(format: format, undiffDirection: undiffDirection)
                    return Token.pair(first: first, separator: format.symbols.nameValueSeparator, second: second)
                }
                return .group(prefix: prefix, subtokens: subtokens, suffix: suffix)
            }

        case .enum(name: let name, caseName: let caseName, associatedValue: .none):
            let formattedName = isRootLevel ? Self.format(typeName: name, including: format.typeNameComponents) : ""
            return .value(String(format: format.symbols.enum, caseName, formattedName))

        case .enum(name: let name, caseName: let caseName, associatedValue: .tuple(let elements)):
            let formattedName = isRootLevel ? Self.format(typeName: name, including: format.typeNameComponents) : ""
            let prefix = String(format: format.symbols.enumWithAVPrefix, caseName, formattedName)
            let suffix = String(format: format.symbols.enumWithAVSuffix, caseName, formattedName)
            if elements == [.omitted(reason: .maxDepthExceeded)] {
                return .value(prefix + format.symbols.omittedMaxDepthExceeded + suffix)
            } else {
                let subtokens = tokenizePairs(elements)
                return .group(prefix: prefix, subtokens: subtokens, suffix: suffix)
            }

        case .enum(name: let name, caseName: let caseName, associatedValue: .some(let associatedValue)):
            let formattedName = isRootLevel ? Self.format(typeName: name, including: format.typeNameComponents) : ""
            let prefix = String(format: format.symbols.enumWithAVPrefix, caseName, formattedName)
            let suffix = String(format: format.symbols.enumWithAVSuffix, caseName, formattedName)
            if associatedValue == .omitted(reason: .maxDepthExceeded) {
                return .value(prefix + format.symbols.omittedMaxDepthExceeded + suffix)
            } else {
                let subtokens = [associatedValue.tokenize(format: format, undiffDirection: undiffDirection)]
                return .group(prefix: prefix, subtokens: subtokens, suffix: suffix)
            }

        case .optional(value: let value):
            return value.map { $0.tokenize(format: format, undiffDirection: undiffDirection) } ??
                .value(format.symbols.nilValue)

        case .set(elements: let elements):
            let prefix = format.symbols.setPrefix
            let suffix = format.symbols.setSuffix
            if elements == [.omitted(reason: .maxDepthExceeded)] {
                return .value(prefix + format.symbols.omittedMaxDepthExceeded + suffix)
            } else {
                let subtokens = elements.map { $0.tokenize(format: format, undiffDirection: undiffDirection) }
                return .group(prefix: prefix, subtokens: subtokens, suffix: suffix)
            }

        case .struct where isDiffStruct:
            let diff = Diff(from: self)!
            let originalToken = diff.original?.tokenize(format: format, undiffDirection: undiffDirection)
            let updateToken = diff.update?.tokenize(format: format, undiffDirection: undiffDirection)
            return .diff(undiffDirection == .original ? originalToken : updateToken)

        case .struct(name: let name, properties: let properties):
            let formattedName = Self.format(typeName: name, including: format.typeNameComponents)
            let prefix = String(format: format.symbols.structPrefix, formattedName)
            let suffix = String(format: format.symbols.structSuffix, formattedName)
            if properties == [.omitted(reason: .maxDepthExceeded)] {
                return .value(prefix + format.symbols.omittedMaxDepthExceeded + suffix)
            } else {
                let subtokens = tokenizePairs(properties)
                return .group(prefix: prefix, subtokens: subtokens, suffix: suffix)
            }

        case .tuple(elements: let elements):
            let prefix = format.symbols.tuplePrefix
            let suffix = format.symbols.tupleSuffix
            if elements == [.omitted(reason: .maxDepthExceeded)] {
                return .value(prefix + format.symbols.omittedMaxDepthExceeded + suffix)
            } else {
                let subtokens = tokenizePairs(elements)
                return .group(prefix: prefix, subtokens: subtokens, suffix: suffix)
            }

        case .value(description: let description):
            return .value(description)

        case .omitted(reason: .filtered):
            return .filtered

        case .omitted(reason: .maxDepthExceeded):
            return .value(format.symbols.omittedMaxDepthExceeded)

        case .omitted(reason: .referenceCycleDetected):
            return .value(format.symbols.omittedRefCycleDetected)

        case .omitted(reason: .unresolved):
            return .value(format.symbols.omittedUnresolved)
        }
    }

    private func process(_ token: Token, hasDiff: Bool? = nil, format: DumpFormat, isRootLevel: Bool = false) -> Token {

        let hasDiff = hasDiff ?? token.containsDiff

        func summarizableRanges(
            from subtokens: [Token],
            indexIsSummarizable: (Int) -> Bool
        ) -> [(start: Int, end: Int)] {

            var summarizableRanges = [(start: Int, end: Int)]()
            var previousIndexIsSummarizable = false
            for index in subtokens.indices {
                let indexIsSummarizable = indexIsSummarizable(index)
                if indexIsSummarizable && !previousIndexIsSummarizable {
                    summarizableRanges.append((start: index, end: index))
                } else if indexIsSummarizable && previousIndexIsSummarizable {
                    summarizableRanges[summarizableRanges.count - 1].end = index
                }
                previousIndexIsSummarizable = indexIsSummarizable
            }

            return summarizableRanges
        }

        func summarizationToken(skipped: Int = 0, unchanged: Int = 0, filtered: Int = 0) -> Token {

            let skippedString = skipped > 0 && skipped != filtered ?
                String(format: format.symbols.summaryEntrySkipped, skipped) : nil
            let unchangedString = unchanged > 0 && unchanged != filtered ?
                String(format: format.symbols.summaryEntryUnchanged, unchanged) : nil
            let filteredString = filtered > 0 ?
                String(format: format.symbols.summaryEntryFiltered, filtered) : nil

            switch (skippedString, unchangedString, filteredString) {
            case (.none, .none, .none):
                assertionFailure()
                return .value(String(format: format.symbols.summarySingleEntry, "?"))

            case (.some(let first), .none, .none),
                (.none, .some(let first), .none),
                (.none, .none, .some(let first)):
                return .value(String(format: format.symbols.summarySingleEntry, first))

            case (.some(let first), .some(let second), .none),
                (.some(let first), .none, .some(let second)),
                (.none, .some(let first), .some(let second)):
                return .value(String(format: format.symbols.summaryDualEntry, first, second))

            case (.some, .some(let first), .some(let second)):
                assertionFailure()
                return .value(String(format: format.symbols.summaryDualEntry, first, second))
            }
        }

        func summarize(_ subtokens: inout [Token]) {

            let halfMaxItems = format.maxItems.quotientAndRemainder(dividingBy: 2)
            let skipStartIndex = halfMaxItems.quotient + halfMaxItems.remainder - 1
            let skipEndIndex = subtokens.count - halfMaxItems.quotient
            let skippedIndicies = Set(subtokens.indices.filter({ $0 > skipStartIndex && $0 < skipEndIndex }))
            let unchangedIndicies = Set(subtokens.indices.filter({ !subtokens[$0].containsDiff }))
            let filteredIndicies = Set(subtokens.indices.filter({ subtokens[$0].isFiltered }))

            if unchangedIndicies.count == subtokens.count {

                // Does not contain diffed elements - Skip excessive and filtered elements.
                let summarizableRanges = summarizableRanges(
                    from: subtokens,
                    indexIsSummarizable: { skippedIndicies.contains($0) || filteredIndicies.contains($0) }
                )
                summarizableRanges.reversed().forEach { (start, end) in
                    let filteredIndicies = filteredIndicies.intersection(start...end)
                    let skipped = skippedIndicies.intersection(start...end).union(filteredIndicies).count
                    let replacementToken = summarizationToken(skipped: skipped, filtered: filteredIndicies.count)
                    subtokens.replaceSubrange(start...end, with: [replacementToken])
                }

            } else {

                // Contains diffed elements - Skip unchanged and filtered elements.
                let summarizableRanges = summarizableRanges(
                    from: subtokens,
                    indexIsSummarizable: { unchangedIndicies.contains($0) || filteredIndicies.contains($0) }
                )
                summarizableRanges.reversed().forEach { (start, end) in
                    let filteredIndicies = filteredIndicies.intersection(start...end)
                    let unchanged = unchangedIndicies.intersection(start...end).union(filteredIndicies).count
                    let replacementToken = summarizationToken(unchanged: unchanged, filtered: filteredIndicies.count)
                    subtokens.replaceSubrange(start...end, with: [replacementToken])
                }
            }
        }

        switch token {
        case .diff(let value):
            return value.map { process($0, hasDiff: nil, format: format) } ?? token

        case .filtered:
            return isRootLevel ? summarizationToken(filtered: 1) : token

        case .group(prefix: let prefix, subtokens: var subtokens, suffix: let suffix):
            summarize(&subtokens)
            subtokens = subtokens.map { process($0, hasDiff: hasDiff ? nil : false, format: format) }
            return .group(prefix: prefix, subtokens: subtokens, suffix: suffix)

        case .pair(first: let first, separator: let separator, second: let second):
            let processedFirst = first.map { process($0, hasDiff: hasDiff ? nil : false, format: format) }
            let processedSecond = process(second, hasDiff: hasDiff ? nil : false, format: format)
            return .pair(first: processedFirst, separator: separator, second: processedSecond)

        case .value:
            return token
        }
    }

    private func print<T: TextOutputStream>(
        _ token: Token,
        to stream: inout T,
        format: DumpFormat,
        terminator: String
    ) {

        func printRecursively<T: TextOutputStream>(
            _ token: Token,
            to stream: inout T,
            indentation: Int,
            nextLine: inout String
        ) {

            switch token {
            case .diff(.none),
                 .filtered:
                break

            case .diff(.some(let value)):
                printRecursively(value, to: &stream, indentation: indentation, nextLine: &nextLine)

            case .group(prefix: let prefix, subtokens: let subtokens, suffix: let suffix):
                let printSingleLine = subtokens.isEmpty || (format.maxLineWidth >= 1 &&
                    token.fits(width: format.maxLineWidth - nextLine.count, format: format))
                if printSingleLine {

                    nextLine += prefix
                    for (index, subtoken) in subtokens.enumerated() where !subtoken.isDeleted {
                        printRecursively(subtoken, to: &stream, indentation: indentation + 1, nextLine: &nextLine)
                        if index < subtokens.count - 1 { nextLine += format.symbols.elementSeparator }
                    }
                    nextLine += suffix

                } else {

                    stream.write("\(nextLine)\(prefix)\n")
                    let separator = format.symbols.elementSeparator.trimmingCharacters(in: .whitespaces)
                    for (index, subtoken) in subtokens.enumerated() where !subtoken.isDeleted {
                        nextLine = "".indented(using: format.symbols.indentationCharacters, count: indentation + 1)
                        printRecursively(subtoken, to: &stream, indentation: indentation + 1, nextLine: &nextLine)
                        if index < subtokens.count - 1 { nextLine += separator }
                        stream.write("\(nextLine)\n")
                    }
                    nextLine = "".indented(using: format.symbols.indentationCharacters, count: indentation) + suffix
                }

            case .pair(first: let first, separator: let separator, second: let second):
                first.flatMap { printRecursively($0, to: &stream, indentation: indentation, nextLine: &nextLine) }
                nextLine += separator
                printRecursively(second, to: &stream, indentation: indentation, nextLine: &nextLine)

            case .value(let value):
                nextLine += value
            }
        }

        var nextLine = ""
        printRecursively(token, to: &stream, indentation: 0, nextLine: &nextLine)

        Swift.print(nextLine, terminator: terminator, to: &stream)
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    private func printDiff<T: TextOutputStream>(
        _ oldToken: Token,
        _ newToken: Token,
        to stream: inout T,
        format: DumpFormat,
        terminator: String
    ) {

        func applyDiff(from oldValue: [Substring], to newValue: [Substring]) -> [String] {

            let diff = newValue.difference(from: oldValue)

            var result = [String]()
            var oldValueOffset = 0
            var newValueOffset = 0

            while oldValueOffset < oldValue.count || newValueOffset < newValue.count {

                let isRemoval = diff.removals.contains { $0.offset == oldValueOffset }
                let isInsertion = diff.insertions.contains { $0.offset == newValueOffset }

                if isRemoval {
                    result.append(oldValue[oldValueOffset].indented(using: format.symbols.diffRemovedLinePrefix))
                    oldValueOffset += 1
                } else if isInsertion {
                    result.append(newValue[newValueOffset].indented(using: format.symbols.diffInsertedLinePrefix))
                    newValueOffset += 1
                } else {
                    result.append(oldValue[oldValueOffset].indented(using: format.symbols.diffUnchangedLinePrefix))
                    oldValueOffset += 1
                    newValueOffset += 1
                }
            }

            return result
        }

        var oldTokenDump = ""
        print(oldToken, to: &oldTokenDump, format: format, terminator: terminator)
        let oldTokenDumpLines = oldTokenDump.split(separator: "\n")

        var newTokenDump = ""
        print(newToken, to: &newTokenDump, format: format, terminator: terminator)
        let newTokenDumpLines = newTokenDump.split(separator: "\n")

        let diffLines = applyDiff(from: oldTokenDumpLines, to: newTokenDumpLines)
        let diff = diffLines.joined(separator: "\n")

        Swift.print(diff, terminator: terminator, to: &stream)
    }
}
