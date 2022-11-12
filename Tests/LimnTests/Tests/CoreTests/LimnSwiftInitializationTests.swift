import XCTest
@testable import Limn

final class LimnSwiftInitializationTests: XCTestCase {

    // MARK: - Initialization tests

    func testSwiftClassInitialization() {

        test(SwiftClass.empty)
        test(SwiftClass.simple)
        test(SwiftClass.simpleSubclass)
        test(SwiftClass.simpleSubSubclass)
        test(SwiftClass.complex)
    }

    func testSwiftCollectionInitialization() {

        test(SwiftCollection.empty)
        test(SwiftCollection.simpleIntArray)
        test(SwiftCollection.simpleStringArray)
        test(SwiftCollection.simple2DStringsArray)
        test(SwiftCollection.simple3DAnyHashableArray)
    }

    func testSwiftDictionaryInitialization() {

        test(SwiftDictionary.empty)
        test(SwiftDictionary.simpleIntIntDictionary)
        test(SwiftDictionary.simpleAnyHashableDictionary)
        test(SwiftDictionary.complexDictionary)
    }

    func testSwiftEnumInitialization() {

        test(SwiftEnum.emptyType)
        test(SwiftEnum.simple_firstCase)
        test(SwiftEnum.simpleWithStringRawType_secondCase)
        test(SwiftEnum.simpleWithAssociatedType_firstCase)
        test(SwiftEnum.simpleWithAssociatedType_secondCase)
        test(SwiftEnum.simpleWithAssociatedType_thirdCase)
        test(SwiftEnum.simpleWithAssociatedType_fourthCase)
        test(SwiftEnum.complexEnum_firstCase)
        test(SwiftEnum.complexEnum_secondCase)
    }

    func testSwiftOptionalInitialization() {

        test(SwiftOptional.noneStringOptional)
        test(SwiftOptional.noneDictionaryOptional)
        test(SwiftOptional.someStringOptional)
        test(SwiftOptional.someDictionaryOptional)
    }

    func testSwiftSetInitialization() {

        test(SwiftSet.empty)
        test(SwiftSet.simpleIntSet)
    }

    func testSwiftStructInitialization() {

        test(SwiftStruct.empty)
        test(SwiftStruct.simple)
    }

    func testSwiftTupleInitialization() {

        test(SwiftTuple.empty)
        test(SwiftTuple.simpleUnlabeled)
        test(SwiftTuple.simpleSemiLabeled)
        test(SwiftTuple.complexLabeledHeterogeneous)
    }

    func testSwiftValueInitialization() {

        test(SwiftValue.expressibleByNilLiteralTypeValue)
        test(SwiftValue.stringTypeValue)
        test(SwiftValue.closureTypeValue)
        test(SwiftValue.stringValue)
        test(SwiftValue.substringValue)
        test(SwiftValue.intValue)
    }

    // MARK: - MaxDepth tests

    func testSwiftClassMaxDepth() {

        XCTAssertEqualLimns(
            Limn(of: SwiftClass.simple.instance, maxDepth: -1),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftClass.simple.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftClass.simple.instance, maxDepth: 1),
            .class(
                name: Limn.typeName(of: SwiftClass.simple.instance),
                address: Limn.address(of: SwiftClass.simple.instance),
                properties: [.omitted(reason: .maxDepthExceeded)]
            )
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftClass.simple.instance, maxDepth: 2),
            SwiftClass.simple.expectedLimn
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftClass.simple.instance, maxDepth: 3),
            SwiftClass.simple.expectedLimn
        )

        XCTAssertEqualLimns(
            Limn(of: SwiftClass.empty.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftClass.empty.instance, maxDepth: 1),
            SwiftClass.empty.expectedLimn
        )
    }

    func testSwiftCollectionMaxDepth() {

        XCTAssertEqualLimns(
            Limn(of: SwiftCollection.simpleIntArray.instance, maxDepth: -1),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftCollection.simpleIntArray.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftCollection.simpleIntArray.instance, maxDepth: 1),
            .collection(elements: [.omitted(reason: .maxDepthExceeded)])
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftCollection.simpleIntArray.instance, maxDepth: 2),
            SwiftCollection.simpleIntArray.expectedLimn
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftCollection.simpleIntArray.instance, maxDepth: 3),
            SwiftCollection.simpleIntArray.expectedLimn
        )

        XCTAssertEqualLimns(
            Limn(of: SwiftCollection.empty.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftCollection.empty.instance, maxDepth: 1),
            SwiftCollection.empty.expectedLimn
        )
    }

    func testSwiftDictionaryMaxDepth() {

        XCTAssertEqualLimns(
            Limn(of: SwiftDictionary.simpleIntIntDictionary.instance, maxDepth: -1),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftDictionary.simpleIntIntDictionary.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftDictionary.simpleIntIntDictionary.instance, maxDepth: 1),
            .dictionary(
                keyValuePairs: [.omitted(reason: .maxDepthExceeded)]
            )
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftDictionary.simpleIntIntDictionary.instance, maxDepth: 2),
            SwiftDictionary.simpleIntIntDictionary.expectedLimn
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftDictionary.simpleIntIntDictionary.instance, maxDepth: 3),
            SwiftDictionary.simpleIntIntDictionary.expectedLimn
        )

        XCTAssertEqualLimns(
            Limn(of: SwiftDictionary.empty.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftDictionary.empty.instance, maxDepth: 1),
            SwiftDictionary.empty.expectedLimn
        )
    }

    func testSwiftEnumMaxDepth() {

        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.simple_firstCase.instance, maxDepth: -1),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.simple_firstCase.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.simple_firstCase.instance, maxDepth: 1),
            SwiftEnum.simple_firstCase.expectedLimn
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.simple_firstCase.instance, maxDepth: 2),
            SwiftEnum.simple_firstCase.expectedLimn
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.simple_firstCase.instance, maxDepth: 3),
            SwiftEnum.simple_firstCase.expectedLimn
        )

        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.complexEnum_secondCase.instance, maxDepth: -1),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.complexEnum_secondCase.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.complexEnum_secondCase.instance, maxDepth: 1),
            .enum(
                name: Limn.typeName(of: SwiftEnum.complexEnum_secondCase.instance),
                caseName: "secondCase",
                associatedValue: .omitted(reason: .maxDepthExceeded)
            )
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.complexEnum_secondCase.instance, maxDepth: 2),
            .enum(
                name: Limn.typeName(of: SwiftEnum.complexEnum_secondCase.instance),
                caseName: "secondCase",
                associatedValue: .tuple(elements: [
                    .init(".0", .optional(value: SwiftEnum.complexEnum_firstCase.expectedLimn)),
                    .init("secondLabel", .collection(elements: [.omitted(reason: .maxDepthExceeded)]))
                ])
            )
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.complexEnum_secondCase.instance, maxDepth: 3),
            SwiftEnum.complexEnum_secondCase.expectedLimn
        )

        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.simpleWithAssociatedType_secondCase.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.simpleWithAssociatedType_secondCase.instance, maxDepth: 1),
            .enum(
                name: "LimnTests.SwiftEnum.SimpleWithAssociatedType",
                caseName: "secondCase",
                associatedValue: .omitted(reason: .maxDepthExceeded)
            )
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftEnum.simpleWithAssociatedType_secondCase.instance, maxDepth: 2),
            SwiftEnum.simpleWithAssociatedType_secondCase.expectedLimn
        )
    }

    func testSwiftOptionalMaxDepth() {

        XCTAssertEqualLimns(
            Limn(of: SwiftOptional.someDictionaryOptional.instance, maxDepth: -1),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftOptional.someDictionaryOptional.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftOptional.someDictionaryOptional.instance, maxDepth: 1),
            .optional(value: .dictionary(keyValuePairs: [.omitted(reason: .maxDepthExceeded)]))
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftOptional.someDictionaryOptional.instance, maxDepth: 2),
            .optional(value:
                    .dictionary(
                        keyValuePairs: arrayMatchingIterationOrder(
                            of: SwiftDictionary.simpleAnyHashableDictionary.instance,
                            with: [
                                1: .init(.value(description: "1"), .value(description: "4.0")),
                                "22": .init(.value(description: "\"22\""), .value(description: "33")),
                                333.0: .init(
                                    .value(description: "333.0"),
                                    .dictionary(keyValuePairs: [.omitted(reason: .maxDepthExceeded)])
                                ),
                                4444: .init(.value(description: "4444"), .value(description: "\"1111\""))
                            ]
                        )
                    )
            )
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftOptional.someDictionaryOptional.instance, maxDepth: 3),
            SwiftOptional.someDictionaryOptional.expectedLimn
        )
    }

    func testSwiftSetMaxDepth() {

        XCTAssertEqualLimns(
            Limn(of: SwiftSet.simpleIntSet.instance, maxDepth: -1),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftSet.simpleIntSet.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftSet.simpleIntSet.instance, maxDepth: 1),
            .set(elements: [.omitted(reason: .maxDepthExceeded)])
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftSet.simpleIntSet.instance, maxDepth: 2),
            SwiftSet.simpleIntSet.expectedLimn
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftSet.simpleIntSet.instance, maxDepth: 3),
            SwiftSet.simpleIntSet.expectedLimn
        )

        XCTAssertEqualLimns(
            Limn(of: SwiftSet.empty.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftSet.empty.instance, maxDepth: 1),
            SwiftSet.empty.expectedLimn
        )
    }

    func testSwiftStructMaxDepth() {

        XCTAssertEqualLimns(
            Limn(of: SwiftStruct.simple.instance, maxDepth: -1),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftStruct.simple.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftStruct.simple.instance, maxDepth: 1),
            .struct(
                name: Limn.typeName(of: SwiftStruct.simple.instance),
                properties: [.omitted(reason: .maxDepthExceeded)]
            )
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftStruct.simple.instance, maxDepth: 2),
            SwiftStruct.simple.expectedLimn
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftStruct.simple.instance, maxDepth: 3),
            SwiftStruct.simple.expectedLimn
        )

        XCTAssertEqualLimns(
            Limn(of: SwiftStruct.empty.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftStruct.empty.instance, maxDepth: 1),
            SwiftStruct.empty.expectedLimn
        )
    }

    func testSwiftTupleMaxDepth() {

        XCTAssertEqualLimns(
            Limn(of: SwiftTuple.simpleSemiLabeled.instance, maxDepth: -1),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftTuple.simpleSemiLabeled.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftTuple.simpleSemiLabeled.instance, maxDepth: 1),
            .tuple(elements: [.omitted(reason: .maxDepthExceeded)])
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftTuple.simpleSemiLabeled.instance, maxDepth: 2),
            SwiftTuple.simpleSemiLabeled.expectedLimn
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftTuple.simpleSemiLabeled.instance, maxDepth: 3),
            SwiftTuple.simpleSemiLabeled.expectedLimn
        )

        XCTAssertEqualLimns(
            Limn(of: SwiftTuple.empty.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftTuple.empty.instance, maxDepth: 1),
            SwiftTuple.empty.expectedLimn
        )
    }

    func testSwiftValueMaxDepth() {

        XCTAssertEqualLimns(
            Limn(of: SwiftValue.stringValue.instance, maxDepth: -1),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftValue.stringValue.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftValue.stringValue.instance, maxDepth: 1),
            SwiftValue.stringValue.expectedLimn
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftValue.stringValue.instance, maxDepth: 2),
            SwiftValue.stringValue.expectedLimn
        )

        XCTAssertEqualLimns(
            Limn(of: SwiftValue.closureTypeValue.instance, maxDepth: -1),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftValue.closureTypeValue.instance, maxDepth: 0),
            .omitted(reason: .maxDepthExceeded)
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftValue.closureTypeValue.instance, maxDepth: 1),
            SwiftValue.closureTypeValue.expectedLimn
        )
        XCTAssertEqualLimns(
            Limn(of: SwiftValue.closureTypeValue.instance, maxDepth: 2),
            SwiftValue.closureTypeValue.expectedLimn
        )
    }

    // MARK: - Other tests

    func testInifiteReferenceCycle() {

        class MyClass {
            var other: MyClass? = nil
        }

        let classA = MyClass()
        let classB = MyClass()
        classA.other = classB
        classB.other = classA
        defer { classB.other = nil }

        XCTAssertEqualLimns(
            Limn(of: classA),
            .class(
                name: Limn.typeName(of: classA),
                address: Limn.address(of: classA),
                properties: [
                    .init("other", .optional(value: .class(
                        name: Limn.typeName(of: classB),
                        address: Limn.address(of: classB),
                        properties: [
                            .init("other", .optional(value: .class(
                                name: Limn.typeName(of: classA),
                                address: Limn.address(of: classA),
                                properties: [.omitted(reason: .referenceCycleDetected)]
                            )))
                        ]
                    )))
                ]
            )
        )
    }

    // MARK: - Private methods

    private func test<T>(_ model: TestModel<T>) {
        let modelLimn = Limn(of: model.instance, maxDepth: .max)
        XCTAssertEqualLimns(modelLimn, model.expectedLimn)
    }
}
