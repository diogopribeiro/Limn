import Limn

enum SwiftDictionary {

    // MARK: - Empty dictionaries

    static let empty: TestModel<[AnyHashable: AnyHashable]> = (
        [:],
        .dictionary(keyValuePairs: [])
    )

    // MARK: - Simple dictionaries

    private static let simpleIntIntDictionaryInstance: [Int: Int] = [
        1: 4,
        22: 33,
        333: 222,
        4444: 1111
    ]
    static let simpleIntIntDictionary: TestModel<[Int: Int]> = (
        simpleIntIntDictionaryInstance,
        .dictionary(keyValuePairs: arrayMatchingIterationOrder(of: simpleIntIntDictionaryInstance, with: [
            1: .init(.value(description: "1"), .value(description: "4")),
            22: .init(.value(description: "22"), .value(description: "33")),
            333: .init(.value(description: "333"), .value(description: "222")),
            4444: .init(.value(description: "4444"), .value(description: "1111"))
        ]))
    )

    private static let simpleAnyHashableDictionaryInstance: [AnyHashable: AnyHashable] = [
        1: 4.0,
        "22": 33,
        333.0: simpleIntIntDictionaryInstance,
        4444: "1111"
    ]
    static let simpleAnyHashableDictionary: TestModel<[AnyHashable: AnyHashable]> = (
        simpleAnyHashableDictionaryInstance,
        .dictionary(keyValuePairs: arrayMatchingIterationOrder(of: simpleAnyHashableDictionaryInstance, with: [
            1: .init(.value(description: "1"), .value(description: "4.0")),
            "22": .init(.value(description: "\"22\""), .value(description: "33")),
            333.0: .init(.value(description: "333.0"), simpleIntIntDictionary.expectedLimn),
            4444: .init(.value(description: "4444"), .value(description: "\"1111\""))
        ]))
    )

    // MARK: - Complex dictionaries

    private static let complexDictionaryInstance: [AnyHashable: Any] = [
        1: simpleIntIntDictionary.instance,
        "2": "secondElement",
        Set([3.0]): SwiftClass.simpleSubSubclass.instance,
        ["4"]: Set(["fourthElement"]),
        [8: "9"]: [4: SwiftCollection.simple3DAnyHashableArray.instance],
    ]
    static let complexDictionary: TestModel<[AnyHashable: Any]> = (
        complexDictionaryInstance,
        .dictionary(keyValuePairs: arrayMatchingIterationOrder(of: complexDictionaryInstance, with: [
            1: .init(
                .value(description: "1"),
                simpleIntIntDictionary.expectedLimn
            ),
            "2": .init(
                .value(description: "\"2\""),
                .value(description: "\"secondElement\"")
            ),
            Set([3.0]): .init(
                .set(elements: [.value(description: "3.0")]),
                SwiftClass.simpleSubSubclass.expectedLimn
            ),
            ["4"]: .init(
                .collection(elements: [.value(description: "\"4\"")]),
                .set(elements: [.value(description: "\"fourthElement\"")])
            ),
            [8: "9"]: .init(
                .dictionary(keyValuePairs: [.init(.value(description: "8"), .value(description: "\"9\""))]),
                .dictionary(keyValuePairs: [
                    .init(.value(description: "4"), SwiftCollection.simple3DAnyHashableArray.expectedLimn)
                ])
            )
        ]))
    )
}
