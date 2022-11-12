import XCTest
@testable import Limn

final class LimnDumpTests: XCTestCase {

    // MARK: Simple instances

    func testSimpleClassDump() {

        let model = SwiftClass.simple.expectedLimn
        let modelAddress = SwiftClass.simpleInstanceAddress
        let narrowOutput = model.stringDump(format: .testNarrowDumpFormat)
        let wideOutput = model.stringDump(format: .testWideDumpFormat)

        XCTAssertEqual(
            narrowOutput,
            """
            Simple(
                firstProperty: 77,
                secondProperty: "Hello world!"
            ) @ \(modelAddress)
            """
        )

        XCTAssertEqual(
            wideOutput,
            """
            Simple(firstProperty: 77, secondProperty: "Hello world!") @ \(modelAddress)
            """
        )
    }

    func testSimpleCollectionDump() {

        let model = SwiftCollection.simpleIntArray.expectedLimn
        let narrowOutput = model.stringDump(format: .testNarrowDumpFormat)
        let wideOutput = model.stringDump(format: .testWideDumpFormat)

        XCTAssertEqual(
            narrowOutput,
            """
            [
                .0: 1,
                .1: 22,
                .2: 333,
                .3: 4444
            ]
            """
        )

        XCTAssertEqual(
            wideOutput,
            """
            [.0: 1, .1: 22, .2: 333, .3: 4444]
            """
        )
    }

    func testSimpleDictionaryDump() {

        let instance = SwiftDictionary.simpleIntIntDictionary.instance
        let model = SwiftDictionary.simpleIntIntDictionary.expectedLimn
        let narrowOutput = model.stringDump(format: .testNarrowDumpFormat)
        let wideOutput = model.stringDump(format: .testWideDumpFormat)

        XCTAssertEqual(
            narrowOutput,
            "[\n" + arrayMatchingIterationOrder(of: instance, with: [
                1: "    1: 4",
                22: "    22: 33",
                333: "    333: 222",
                4444: "    4444: 1111"
            ]).joined(separator: ",\n") + "\n]"
        )

        XCTAssertEqual(
            wideOutput,
            "[" + arrayMatchingIterationOrder(of: instance, with: [
                1: "1: 4",
                22: "22: 33",
                333: "333: 222",
                4444: "4444: 1111"
            ]).joined(separator: ", ") + "]"
        )
    }

    func testSimpleEnumDump() {

        let model = SwiftEnum.simpleWithAssociatedType_secondCase.expectedLimn
        let narrowOutput = model.stringDump(format: .testNarrowDumpFormat)
        let wideOutput = model.stringDump(format: .testWideDumpFormat)

        XCTAssertEqual(
            narrowOutput,
            """
            SimpleWithAssociatedType.secondCase(
                "mySecondCaseValue"
            )
            """
        )

        XCTAssertEqual(
            wideOutput,
            """
            SimpleWithAssociatedType.secondCase("mySecondCaseValue")
            """
        )
    }

    func testSimpleOptionalDump() {

        let model = SwiftOptional.noneStringOptional.expectedLimn
        let narrowOutput = model.stringDump(format: .testNarrowDumpFormat)
        let wideOutput = model.stringDump(format: .testWideDumpFormat)

        XCTAssertEqual(
            narrowOutput,
            """
            nil
            """
        )

        XCTAssertEqual(
            wideOutput,
            """
            nil
            """
        )
    }

    func testSimpleSetDump() {

        let instance = SwiftSet.simpleIntSet.instance
        let model = SwiftSet.simpleIntSet.expectedLimn
        let narrowOutput = model.stringDump(format: .testNarrowDumpFormat)
        let wideOutput = model.stringDump(format: .testWideDumpFormat)

        XCTAssertEqual(
            narrowOutput,
            "Set([\n" + arrayMatchingIterationOrder(of: instance, with: [
                1: "    1",
                22: "    22",
                333: "    333",
                4444: "    4444"
            ]).joined(separator: ",\n") + "\n])"
        )

        XCTAssertEqual(
            wideOutput,
            "Set([" + arrayMatchingIterationOrder(of: instance, with: [
                1: "1",
                22: "22",
                333: "333",
                4444: "4444"
            ]).joined(separator: ", ") + "])"
        )
    }

    func testSimpleStructDump() {

        let model = SwiftStruct.simple.expectedLimn
        let narrowOutput = model.stringDump(format: .testNarrowDumpFormat)
        let wideOutput = model.stringDump(format: .testWideDumpFormat)

        XCTAssertEqual(
            narrowOutput,
            """
            Simple(
                firstProperty: 77,
                secondProperty: "Hello world!",
                thirdProperty: 3.14,
                fourthProperty: false
            )
            """
        )

        XCTAssertEqual(
            wideOutput,
            """
            Simple(firstProperty: 77, secondProperty: "Hello world!", thirdProperty: 3.14, fourthProperty: false)
            """
        )
    }

    func testSimpleTupleDump() {

        let model = SwiftTuple.simpleSemiLabeled.expectedLimn
        let narrowOutput = model.stringDump(format: .testNarrowDumpFormat)
        let wideOutput = model.stringDump(format: .testWideDumpFormat)

        XCTAssertEqual(
            narrowOutput,
            """
            (
                .0: "firstValue",
                secondLabel: 99,
                afterSecondLabel: 3.0,
                .3: true
            )
            """
        )

        XCTAssertEqual(
            wideOutput,
            """
            (.0: "firstValue", secondLabel: 99, afterSecondLabel: 3.0, .3: true)
            """
        )
    }

    func testSimpleValueDump() {

        let model = SwiftValue.stringValue.expectedLimn
        let narrowOutput = model.stringDump(format: .testNarrowDumpFormat)
        let wideOutput = model.stringDump(format: .testWideDumpFormat)

        XCTAssertEqual(
            narrowOutput,
            #""Hello\nWorld!""#
        )

        XCTAssertEqual(
            wideOutput,
            #""Hello\nWorld!""#
        )
    }

    // MARK: Formatting

    func testFormattingOptions() {

        let instance = (0..<10).map { i in (0..<(10-i)).map { $0 } }
        let limn = Limn(of: instance, maxDepth: .max)
        var dumpFormat = Limn.DumpFormat.testNarrowDumpFormat
        dumpFormat.collectionIndexMinItems = Int.max
        dumpFormat.maxItems = 3
        dumpFormat.maxLineWidth = 0
        var dumpOutput = limn.stringDump(format: dumpFormat)

        XCTAssertEqual(
            dumpOutput,
            """
            [
                [
                    0,
                    1,
                    … (7 more),
                    9
                ],
                [
                    0,
                    1,
                    … (6 more),
                    8
                ],
                … (7 more),
                [
                    0
                ]
            ]
            """
        )

        dumpFormat.maxLineWidth = Int.max
        dumpOutput = limn.stringDump(format: dumpFormat)

        XCTAssertEqual(
            dumpOutput,
            """
            [[0, 1, … (7 more), 9], [0, 1, … (6 more), 8], … (7 more), [0]]
            """
        )
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    func testDiffedComplexClassDump() {

        let beforeInstance = SwiftClass.diffedComplexInstance_before
        let afterInstance = SwiftClass.diffedComplexInstance_after
        let limn = Limn.diff(from: beforeInstance, to: afterInstance)
        let narrowOutput = limn.stringDump(format: .testNarrowDumpFormat)

        XCTAssertEqual(
            narrowOutput,
            """
            - Complex<Int, Set<Float>>(
            + Complex<Float, Set<String>>(
                  … (2 unchanged),
            -     privateProperty: 77,
            +     privateProperty: 77.0,
                  … (1 unchanged),
                  collectionProperty: [
                      … (1 unchanged),
            -         [
            -             "Hello world!"
            -         ]
                  ],
                  … (2 unchanged),
            -     optionalSomeProperty: "Hello world!",
            +     optionalSomeProperty: "new",
                  … (2 unchanged),
                  structProperty: Simple(
                      … (3 unchanged),
            -         fourthProperty: false
            +         fourthProperty: true
                  ),
                  … (1 unchanged)
            - ) @ \(Limn.address(of: beforeInstance))
            + ) @ \(Limn.address(of: afterInstance))
            """
        )
    }

    // MARK: Other test cases

    func testAllFilteredDump() {

        XCTAssertEqual(
            Limn(of: SwiftClass.simple.instance).filtered(value: "!").stringDump(format: .testNarrowDumpFormat),
            """
            … (1 filtered)
            """
        )

        XCTAssertEqual(
            Limn(of: SwiftCollection.simpleIntArray.instance)
                .filtered(value: "!")
                .stringDump(format: .testNarrowDumpFormat),
            """
            … (1 filtered)
            """
        )
    }

    func testSkippedAndFilteredDump() {

        var dumpFormat = Limn.DumpFormat.default
        dumpFormat.maxLineWidth = 0
        dumpFormat.collectionIndexMinItems = .max
        dumpFormat.maxItems = 4

        let modelA = (0..<100).map { $0 }
        let modelALimn = Limn(of: modelA)

        XCTAssertEqual(
            modelALimn.filtered(value: "*0*").stringDump(format: dumpFormat),
            """
            [
                0,
                … (99 more with 90 filtered)
            ]
            """
        )

        XCTAssertEqual(
            modelALimn.filtered(value: "*9*").stringDump(format: dumpFormat),
            """
            [
                … (98 more with 81 filtered),
                98,
                99
            ]
            """
        )
    }
}

// MARK: - Private extensions

private extension Limn.DumpFormat {

    static let testNarrowDumpFormat = Self(
        maxItems: 32,
        maxLineWidth: 1,
        collectionIndexMinItems: 3,
        typeNameComponents: [.genericTypeParameterNames],
        symbols: .default
    )

    static let testWideDumpFormat = Self(
        maxItems: 32,
        maxLineWidth: .max,
        collectionIndexMinItems: 3,
        typeNameComponents: [.genericTypeParameterNames],
        symbols: .default
    )
}
