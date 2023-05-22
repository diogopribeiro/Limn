extension Collection {

    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
extension CollectionDifference.Change {

    var offset: Int {

        switch self {
        case .insert(offset: let offset, element: _, associatedWith: _),
             .remove(offset: let offset, element: _, associatedWith: _):
            return offset
        }
    }
}

extension Sequence {

    func chunked(by chunkSize: Int, includingRemainder: Bool = true) -> [[Element]] {

        var chunks: [[Self.Element]] = []
        var iterator = makeIterator()

        while let first = iterator.next() {

            var currentChunk = [first]

            while currentChunk.count < chunkSize, let next = iterator.next() {
                currentChunk.append(next)
            }

            if includingRemainder || currentChunk.count == chunkSize {
                chunks.append(currentChunk)
            }
        }

        return chunks
    }

    func sorted<T: Comparable>(
        by keyPath: KeyPath<Element, T>,
        using comparator: (T, T) -> Bool = (<)
    ) -> [Element] {

        sorted { lhs, rhs in
            comparator(lhs[keyPath: keyPath], rhs[keyPath: keyPath])
        }
    }
}

extension StringProtocol {

    func indented(using prefix: String = "    ", count: Int = 1) -> String {

        assert(count >= 0, "'count' must be a value higher or equal to 0")
        guard count > 0 else {
            return String(self)
        }

        let finalPrefix = (0..<Swift.max(1, count)).map { _ in prefix }.joined()
        return finalPrefix + replacingOccurrences(of: "\n", with: "\n\(finalPrefix)")
    }
}

extension UnsafeRawPointer {

    func alignedUp<T>(for type: T.Type) -> Self {

        let stride = MemoryLayout<T>.stride
        let offset = Int(bitPattern: self) % stride
        let alignedPointer = self + (offset > 0 ? stride - offset : 0)

        return alignedPointer
    }
}
