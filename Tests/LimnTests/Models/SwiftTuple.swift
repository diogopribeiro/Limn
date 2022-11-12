import Limn

enum SwiftTuple {

    // MARK: - Empty tuple

    static let empty: TestModel<()> = (
        (),
        .tuple(elements: [])
    )

    // MARK: - Simple tuples

    static let simpleUnlabeled: TestModel<(Int, String)> = (
        (83, "secondValue"),
        .tuple(elements: [
            .init(".0", .value(description: "83")),
            .init(".1", .value(description: "\"secondValue\""))
        ])
    )

    static let simpleSemiLabeled: TestModel<(String, secondLabel: Int, afterSecondLabel: Float, Bool)> = (
        ("firstValue", secondLabel: 99, afterSecondLabel: 3.0, true),
        .tuple(elements: [
            .init(".0", .value(description: "\"firstValue\"")),
            .init("secondLabel", .value(description: "99")),
            .init("afterSecondLabel", .value(description: "3.0")),
            .init(".3", .value(description: "true"))
        ])
    )

    // MARK: - Complex tuples

    typealias ComplexLabeledHeterogeneous = (
        first: [[[AnyHashable]]],
        second: SwiftClass.SimpleSubclass,
        third: SwiftEnum.SimpleWithAssociatedType
    )
    static let complexLabeledHeterogeneous: TestModel<ComplexLabeledHeterogeneous> = (
        (
            first: SwiftCollection.simple3DAnyHashableArray.instance,
            second: SwiftClass.simpleSubclass.instance,
            third: SwiftEnum.simpleWithAssociatedType_secondCase.instance
        ),
        .tuple(elements: [
            .init("first", SwiftCollection.simple3DAnyHashableArray.expectedLimn),
            .init("second", SwiftClass.simpleSubclass.expectedLimn),
            .init("third", SwiftEnum.simpleWithAssociatedType_secondCase.expectedLimn)
        ])
    )
}
