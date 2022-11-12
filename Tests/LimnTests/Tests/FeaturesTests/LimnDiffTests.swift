import XCTest
@testable import Limn

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
final class LimnDiffTests: XCTestCase {

    // MARK: Diffing by type test cases

    func testClassDiff() {

        let classA = SwiftClass.Simple()
        let classB = SwiftClass.Simple()
        let diffAB = Limn.diff(from: classA, to: classB)

        XCTAssertTrue(diffAB.containsDiff)

        XCTAssertEqualLimns(
            diffAB,
            Limn.Diff(
                original: .class(
                    name: Limn.typeName(of: classA),
                    address: Limn.address(of: classA),
                    properties: [
                        .init("firstProperty", .value(description: "77")),
                        .init("secondProperty", .value(description: "\"Hello world!\""))
                    ]
                ),
                update: .class(
                    name: Limn.typeName(of: classB),
                    address: Limn.address(of: classB),
                    properties: [
                        .init("firstProperty", .value(description: "77")),
                        .init("secondProperty", .value(description: "\"Hello world!\""))
                    ]
                )
            ).limnValue
        )

        let classAOldLimn = Limn(of: classA)
        classA.secondProperty = "Test"
        let classANewLimn = Limn(of: classA)
        let diffAA = classAOldLimn.diffed(to: classANewLimn)

        XCTAssertTrue(diffAA.containsDiff)

        XCTAssertEqualLimns(
            diffAA,
            .class(
                name: Limn.typeName(of: classA),
                address: Limn.address(of: classA),
                properties: [
                    .init("firstProperty", .value(description: "77")),
                    .init("secondProperty", Limn.Diff(
                        original: .value(description: "\"Hello world!\""),
                        update: .value(description: "\"Test\"")
                    ).limnValue)
                ]
            )
        )
    }

    func testCollectionDiff() {

        let collectionA = [   2, 3, 4, 5]
        let collectionB = [1, 2, 9, 4]
        let diffAB = Limn.diff(from: collectionA, to: collectionB)
        let diffBA = Limn.diff(from: collectionB, to: collectionA)

        XCTAssertTrue(diffAB.containsDiff)
        XCTAssertTrue(diffBA.containsDiff)

        XCTAssertEqualLimns(
            diffAB,
            .collection(
                elements: [
                    Limn.Diff(original: nil, update: .value(description: "1")).limnValue,
                    .value(description: "2"),
                    Limn.Diff(original: .value(description: "3"), update: .value(description: "9")).limnValue,
                    .value(description: "4"),
                    Limn.Diff(original: .value(description: "5"), update: nil).limnValue
                ]
            )
        )

        XCTAssertEqualLimns(
            diffBA,
            .collection(
                elements: [
                    Limn.Diff(original: .value(description: "1"), update: nil).limnValue,
                    .value(description: "2"),
                    Limn.Diff(original: .value(description: "9"), update: .value(description: "3")).limnValue,
                    .value(description: "4"),
                    Limn.Diff(original: nil, update: .value(description: "5")).limnValue
                ]
            )
        )

        let collectionC: [AnyHashable] = [1, 2, [5, 6   ], 4]
        let collectionD: [AnyHashable] = [1, 2, [   6, 7], 4]
        let diffCD = Limn.diff(from: collectionC, to: collectionD)
        let diffDC = Limn.diff(from: collectionD, to: collectionC)

        XCTAssertTrue(diffCD.containsDiff)
        XCTAssertTrue(diffDC.containsDiff)

        XCTAssertEqualLimns(
            diffCD,
            .collection(
                elements: [
                    .value(description: "1"),
                    .value(description: "2"),
                    .collection(elements: [
                        Limn.Diff(original: .value(description: "5"), update: nil).limnValue,
                        .value(description: "6"),
                        Limn.Diff(original: nil, update: .value(description: "7")).limnValue
                    ]),
                    .value(description: "4"),
                ]
            )
        )

        XCTAssertEqualLimns(
            diffDC,
            .collection(
                elements: [
                    .value(description: "1"),
                    .value(description: "2"),
                    .collection(elements: [
                        Limn.Diff(original: nil, update: .value(description: "5")).limnValue,
                        .value(description: "6"),
                        Limn.Diff(original: .value(description: "7"), update: nil).limnValue
                    ]),
                    .value(description: "4"),
                ]
            )
        )
    }

    func testDictionaryDiff() {

        let dictionaryA = [        2:  "2", 23: "24", 4: "4", 5: "5"]
        let dictionaryB = [1: "1", 2: "56", 25: "24", 4: "4"        ]
        let diffAB = Limn.diff(from: dictionaryA, to: dictionaryB)
        let diffBA = Limn.diff(from: dictionaryB, to: dictionaryA)

        XCTAssertTrue(diffAB.containsDiff)
        XCTAssertTrue(diffBA.containsDiff)

        guard
            case .dictionary(let diffABKeyValuePairs) = diffAB,
            case .dictionary(let diffBAKeyValuePairs) = diffBA
        else {
            return
        }

        let expectedDiffABKeyValuePairs: [KeyedLimn] = [
            .init(
                Limn.Diff(original: nil, update: .value(description: "1")).limnValue,
                Limn.Diff(original: nil, update: .value(description: "\"1\"")).limnValue
            ),
            .init(
                .value(description: "2"),
                Limn.Diff(
                    original: .value(description: "\"2\""),
                    update: .value(description: "\"56\"")
                ).limnValue
            ),
            .init(
                Limn.Diff(original: .value(description: "23"), update: nil).limnValue,
                Limn.Diff(original: .value(description: "\"24\""), update: nil).limnValue
            ),
            .init(
                Limn.Diff(original: nil, update: .value(description: "25")).limnValue,
                Limn.Diff(original: nil, update: .value(description: "\"24\"")).limnValue
            ),
            .init(.value(description: "4"), .value(description: "\"4\"")),
            .init(
                Limn.Diff(original: .value(description: "5"), update: nil).limnValue,
                Limn.Diff(original: .value(description: "\"5\""), update: nil).limnValue
            )
        ]

        XCTAssertEqualLimns(
            .dictionary(keyValuePairs: diffABKeyValuePairs.sorted(by: \.hashValue)),
            .dictionary(keyValuePairs: expectedDiffABKeyValuePairs.sorted(by: \.hashValue))
        )

        let expectedDiffBAKeyValuePairs: [KeyedLimn] = [
            .init(
                Limn.Diff(original: .value(description: "1"), update: nil).limnValue,
                Limn.Diff(original: .value(description: "\"1\""), update: nil).limnValue
            ),
            .init(
                .value(description: "2"),
                Limn.Diff(
                    original: .value(description: "\"56\""),
                    update: .value(description: "\"2\"")
                ).limnValue
            ),
            .init(
                Limn.Diff(original: nil, update: .value(description: "23")).limnValue,
                Limn.Diff(original: nil, update: .value(description: "\"24\"")).limnValue
            ),
            .init(
                Limn.Diff(original: .value(description: "25"), update: nil).limnValue,
                Limn.Diff(original: .value(description: "\"24\""), update: nil).limnValue
            ),
            .init(.value(description: "4"), .value(description: "\"4\"")),
            .init(
                Limn.Diff(original: nil, update: .value(description: "5")).limnValue,
                Limn.Diff(original: nil, update: .value(description: "\"5\"")).limnValue
            )
        ]

        XCTAssertEqualLimns(
            .dictionary(keyValuePairs: diffBAKeyValuePairs.sorted(by: \.hashValue)),
            .dictionary(keyValuePairs: expectedDiffBAKeyValuePairs.sorted(by: \.hashValue))
        )
    }

    func testEnumDiff() {

        var enumA = SwiftEnum.complexEnum_firstCase.instance
        var enumB = SwiftEnum.ComplexEnum.firstCase
        var diffAB = Limn.diff(from: enumA, to: enumB)

        XCTAssertFalse(diffAB.containsDiff)

        XCTAssertEqualLimns(
            diffAB,
            SwiftEnum.complexEnum_firstCase.expectedLimn
        )

        enumB = SwiftEnum.complexEnum_secondCase.instance
        diffAB = Limn.diff(from: enumA, to: enumB)

        XCTAssertEqualLimns(
            diffAB,
            Limn.Diff(
                original: SwiftEnum.complexEnum_firstCase.expectedLimn,
                update: SwiftEnum.complexEnum_secondCase.expectedLimn
            ).limnValue
        )

        enumA = SwiftEnum.ComplexEnum.secondCase((.firstCase, secondLabel: ["Hello", "Worlds!"]))
        diffAB = Limn.diff(from: enumA, to: enumB)

        XCTAssertEqualLimns(
            diffAB,
            .enum(
                name: "LimnTests.SwiftEnum.ComplexEnum",
                caseName: "secondCase",
                associatedValue: .tuple(elements: [
                    .init(".0", .optional(value: SwiftEnum.complexEnum_firstCase.expectedLimn)),
                    .init("secondLabel", .collection(elements: [
                        .value(description: "\"Hello\""),
                        Limn.Diff(
                            original: .value(description: "\"Worlds!\""),
                            update: .value(description: "\"World!\"")
                        ).limnValue
                    ]))
                ])
            )
        )
    }

    func testOptionalDiff() {

        var optionalA: String? = ""
        var optionalB: String? = nil
        var diffAB = Limn.diff(from: optionalA, to: optionalB)

        XCTAssertTrue(diffAB.containsDiff)

        XCTAssertEqualLimns(
            diffAB,
            Limn.Diff(
                original: .optional(value: .value(description: "\"\"")),
                update: .optional(value: nil)
            ).limnValue
        )

        optionalA = nil
        diffAB = Limn.diff(from: optionalA, to: optionalB)

        XCTAssertEqualLimns(
            diffAB,
            .optional(value: nil)
        )

        optionalA = "1"
        optionalB = "2"
        diffAB = Limn.diff(from: optionalA, to: optionalB)

        XCTAssertEqualLimns(
            diffAB,
            .optional(
                value: Limn.Diff(
                    original: .value(description: "\"1\""),
                    update: .value(description: "\"2\"")
                ).limnValue
            )
        )
    }

    func testSetDiff() {

        let setA = Set<AnyHashable>([   [2, 9], [3, 23], 4, 5])
        let setB = Set<AnyHashable>([1, [2, 9], [3, 25], 4   ])
        let diffAB = Limn.diff(from: setA, to: setB)
        let diffBA = Limn.diff(from: setB, to: setA)

        XCTAssertTrue(diffAB.containsDiff)
        XCTAssertTrue(diffBA.containsDiff)

        let expectedDiffABElements: [Limn] = [
            Limn.Diff(update: .value(description: "1")).limnValue,
            .collection(elements: [
                .value(description: "2"),
                .value(description: "9"),
            ]),
            Limn.Diff(
                original: .collection(elements: [
                    .value(description: "3"),
                    .value(description: "23"),
                ])
            ).limnValue,
            Limn.Diff(
                update: .collection(elements: [
                    .value(description: "3"),
                    .value(description: "25"),
                ])
            ).limnValue,
            .value(description: "4"),
            Limn.Diff(original: .value(description: "5")).limnValue
        ]

        XCTAssertEqualLimns(
            diffAB.sorted(),
            .set(elements: expectedDiffABElements).sorted()
        )

        let expectedDiffBAElements: [Limn] = [
            Limn.Diff(original: .value(description: "1"), update: nil).limnValue,
            .collection(elements: [
                .value(description: "2"),
                .value(description: "9"),
            ]),
            Limn.Diff(
                update: .collection(elements: [
                    .value(description: "3"),
                    .value(description: "23"),
                ])
            ).limnValue,
            Limn.Diff(
                original: .collection(elements: [
                    .value(description: "3"),
                    .value(description: "25"),
                ])
            ).limnValue,
            .value(description: "4"),
            Limn.Diff(original: nil, update: .value(description: "5")).limnValue
        ]

        XCTAssertEqualLimns(
            diffBA.sorted(),
            .set(elements: expectedDiffBAElements).sorted()
        )
    }

    func testStructDiff() {

        var structA = SwiftStruct.Simple()
        let StructB = SwiftStruct.Simple()
        let diffAB = Limn.diff(from: structA, to: StructB)

        XCTAssertFalse(diffAB.containsDiff)

        XCTAssertEqualLimns(
            diffAB,
            SwiftStruct.simple.expectedLimn
        )

        let structAOldLimn = Limn(of: structA)
        structA.firstProperty = 99
        let structANewLimn = Limn(of: structA)
        let diffAA = structAOldLimn.diffed(to: structANewLimn)

        XCTAssertTrue(diffAA.containsDiff)

        XCTAssertEqualLimns(
            diffAA,
            .struct(
                name: Limn.typeName(of: structA),
                properties: [
                    .init("firstProperty", Limn.Diff(
                        original: .value(description: "77"),
                        update: .value(description: "99")
                    ).limnValue),
                    .init("secondProperty", .value(description: "\"Hello world!\"")),
                    .init("thirdProperty", .value(description: "3.14")),
                    .init("fourthProperty", .value(description: "false"))
                ]
            )
        )
    }

    func testTupleDiff() {

        let tupleA: (String, Int) = ("1", 2)
        let tupleB: (firstLabel: String, Int) = (firstLabel: "1", 2)

        let diffAA = Limn.diff(from: tupleA, to: tupleA)

        XCTAssertFalse(diffAA.containsDiff)

        XCTAssertEqualLimns(
            diffAA,
            .tuple(
                elements: [
                    .init(".0", .value(description: "\"1\"")),
                    .init(".1", .value(description: "2"))
                ]
            )
        )

        let tupleALimn = Limn(of: tupleA)
        let tupleBLimn = Limn(of: tupleB)
        let diffAB = tupleALimn.diffed(to: tupleBLimn)

        XCTAssertTrue(diffAB.containsDiff)

        XCTAssertEqualLimns(
            diffAB,
            Limn.Diff(
                original: .tuple(
                    elements: [
                        .init(".0", .value(description: "\"1\"")),
                        .init(".1", .value(description: "2"))
                    ]
                ),
                update: .tuple(
                    elements: [
                        .init("firstLabel", .value(description: "\"1\"")),
                        .init(".1", .value(description: "2"))
                    ]
                )
            ).limnValue
        )

        let tupleC: (String, Int) = ("3", 4)
        let tupleD: (Int, Float) = (5, 6.7)

        let tupleCLimn = Limn(of: tupleC)
        let tupleDLimn = Limn(of: tupleD)
        let diffCD = tupleCLimn.diffed(to: tupleDLimn)

        XCTAssertTrue(diffCD.containsDiff)

        XCTAssertEqualLimns(
            diffCD,
            .tuple(
                elements: [
                    .init(".0", Limn.Diff(
                        original: .value(description: "\"3\""),
                        update: .value(description: "5")
                    ).limnValue),
                    .init(".1", Limn.Diff(
                        original: .value(description: "4"),
                        update: .value(description: "6.7")
                    ).limnValue)
                ]
            )
        )
    }

    func testValueDiff() {

        var valueA: Any = "Test"
        var valueB: Any = "Test"
        var diffAB = Limn.diff(from: valueA, to: valueB)

        XCTAssertFalse(diffAB.containsDiff)

        XCTAssertEqualLimns(
            diffAB,
            .value(description: "\"Test\"")
        )

        valueB = nil as String? as Any
        diffAB = Limn.diff(from: valueA, to: valueB)

        XCTAssertTrue(diffAB.containsDiff)

        XCTAssertEqualLimns(
            diffAB,
            Limn.Diff(
                original: .value(description: "\"Test\""),
                update: .optional(value: nil)
            ).limnValue
        )

        valueA = 2
        valueB = SwiftClass.simple.instance
        let diffBA = Limn.diff(from: valueB, to: valueA)

        XCTAssertTrue(diffBA.containsDiff)

        XCTAssertEqualLimns(
            diffBA,
            Limn.Diff(
                original: SwiftClass.simple.expectedLimn,
                update: .value(description: "2")
            ).limnValue
        )
    }

    func testOmittedDiff() {

        let limnA = Limn.omitted(reason: .maxDepthExceeded)
        let limnB = Limn.omitted(reason: .filtered)
        let diffAB = limnA.diffed(to: limnB)

        XCTAssertTrue(diffAB.containsDiff)

        XCTAssertEqualLimns(
            diffAB,
            Limn.Diff(
                original: .omitted(reason: .maxDepthExceeded),
                update: .omitted(reason: .filtered)
            ).limnValue
        )
    }

    // MARK: Other test cases

    func testPassingValueToDiffedIsEqualToPassingLimnOfValue() {

        let collectionA: [AnyHashable] = [1, 2, [5, 6   ], 4]
        let collectionB: [AnyHashable] = [1, 2, [   6, 7], 4]

        XCTAssertEqualLimns(
            Limn(of: collectionA).diffed(to: collectionB),
            Limn(of: collectionA).diffed(to: Limn(of: collectionB))
        )
    }
}
