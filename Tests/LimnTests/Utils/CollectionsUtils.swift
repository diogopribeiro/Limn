func arrayMatchingIterationOrder<Key, Value, Element>(
    of dictionary: [Key: Value],
    with keyValuePairs: [Key: Element]
) -> [Element] {

    dictionary.map { (key, _) -> Element in
        keyValuePairs[key]!
    }
}

func arrayMatchingIterationOrder<Key, Element>(
    of set: Set<Key>,
    with keyValuePairs: [Key: Element]
) -> [Element] {

    set.map { key -> Element in
        keyValuePairs[key]!
    }
}
