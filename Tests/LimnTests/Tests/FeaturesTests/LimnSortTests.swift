import XCTest
@testable import Limn

final class LimnSortTests: XCTestCase {

    func testClassPropertySorting() {

        class SortableClass {
            let FirstProperty = 1
            let anotherProperty = 1
            let myLastProperty = 1
            let afterLastProperty = 1
        }

        let expectedDefaultDescendingOrderProperties: [LabeledLimn] = [
            .init("myLastProperty", .value(description: "1")),
            .init("anotherProperty", .value(description: "1")),
            .init("afterLastProperty", .value(description: "1")),
            .init("FirstProperty", .value(description: "1"))
        ]

        let expectedCaseInsensitiveDescendingOrderProperties: [LabeledLimn] = [
            .init("myLastProperty", .value(description: "1")),
            .init("FirstProperty", .value(description: "1")),
            .init("anotherProperty", .value(description: "1")),
            .init("afterLastProperty", .value(description: "1"))
        ]

        let value = SortableClass()
        let limn = Limn(of: value)

        XCTAssertEqualLimns(
            limn.sorted(order: .descending, options: [.caseInsensitive]),
            .class(
                name: Limn.typeName(of: value),
                address: Limn.address(of: value),
                properties: expectedCaseInsensitiveDescendingOrderProperties
            )
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .ascending, options: [.caseInsensitive]),
            .class(
                name: Limn.typeName(of: value),
                address: Limn.address(of: value),
                properties: expectedCaseInsensitiveDescendingOrderProperties.reversed()
            )
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .descending, options: []),
            .class(
                name: Limn.typeName(of: value),
                address: Limn.address(of: value),
                properties: expectedDefaultDescendingOrderProperties
            )
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .ascending, options: []),
            .class(
                name: Limn.typeName(of: value),
                address: Limn.address(of: value),
                properties: expectedDefaultDescendingOrderProperties.reversed()
            )
        )
    }

    func testStructPropertySorting() {

        struct SortableStruct {
            let FirstProperty = 1
            let anotherProperty = 1
            let myLastProperty = 1
            let afterLastProperty = 1
        }

        let expectedDefaultDescendingOrderProperties: [LabeledLimn] = [
            .init("myLastProperty", .value(description: "1")),
            .init("anotherProperty", .value(description: "1")),
            .init("afterLastProperty", .value(description: "1")),
            .init("FirstProperty", .value(description: "1"))
        ]

        let expectedCaseInsensitiveDescendingOrderProperties: [LabeledLimn] = [
            .init("myLastProperty", .value(description: "1")),
            .init("FirstProperty", .value(description: "1")),
            .init("anotherProperty", .value(description: "1")),
            .init("afterLastProperty", .value(description: "1"))
        ]

        let value = SortableStruct()
        let limn = Limn(of: value)

        XCTAssertEqualLimns(
            limn.sorted(order: .descending, options: [.caseInsensitive]),
            .struct(
                name: Limn.typeName(of: value),
                properties: expectedCaseInsensitiveDescendingOrderProperties
            )
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .ascending, options: [.caseInsensitive]),
            .struct(
                name: Limn.typeName(of: value),
                properties: expectedCaseInsensitiveDescendingOrderProperties.reversed()
            )
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .descending, options: []),
            .struct(
                name: Limn.typeName(of: value),
                properties: expectedDefaultDescendingOrderProperties
            )
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .ascending, options: []),
            .struct(
                name: Limn.typeName(of: value),
                properties: expectedDefaultDescendingOrderProperties.reversed()
            )
        )
    }

    func testCollectionElementsSorting() {

        let testCollection: [AnyHashable] = [
            8,
            "value",
            2,
            "01",
            "  7",
            4.0,
            "2.0"
        ]

        let expectedNumericDescendingElementsOrder: [Limn] = [
            .value(description: "8"),
            .value(description: "\"value\""),
            .value(description: "2"),
            .value(description: "\"01\""),
            .value(description: "\"  7\""),
            .value(description: "4.0"),
            .value(description: "\"2.0\"")
        ]

        let limn = Limn(of: testCollection)

        XCTAssertEqualLimns(
            limn.sorted(order: .descending, options: [.numeric]),
            .collection(elements: expectedNumericDescendingElementsOrder)
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .ascending, options: [.numeric]),
            .collection(elements: expectedNumericDescendingElementsOrder)
        )
    }

    func testDictionaryKeySorting() {

        let testDictionary: [AnyHashable: AnyHashable] = [
            8: 1,
            "value": 1,
            2: 1,
            "2. Two": 1,
            "17. Seventeen": 1,
            "1. One": 1,
            "  7": 1,
            4.0: 1,
            22: 1,
            "2.0": 1
        ]

        let expectedDefaultDescendingOrderKeyValuePairs: [KeyedLimn] = [
            .init(.value(description: "8"), .value(description: "1")),
            .init(.value(description: "4.0"), .value(description: "1")),
            .init(.value(description: "22"), .value(description: "1")),
            .init(.value(description: "2"), .value(description: "1")),
            .init(.value(description: "\"value\""), .value(description: "1")),
            .init(.value(description: "\"2.0\""), .value(description: "1")),
            .init(.value(description: "\"2. Two\""), .value(description: "1")),
            .init(.value(description: "\"17. Seventeen\""), .value(description: "1")),
            .init(.value(description: "\"1. One\""), .value(description: "1")),
            .init(.value(description: "\"  7\""), .value(description: "1"))
        ]
        let expectedNumericDescendingOrderKeyValuePairs: [KeyedLimn] = [
            .init(.value(description: "22"), .value(description: "1")),
            .init(.value(description: "8"), .value(description: "1")),
            .init(.value(description: "4.0"), .value(description: "1")),
            .init(.value(description: "2"), .value(description: "1")),
            .init(.value(description: "\"value\""), .value(description: "1")),
            .init(.value(description: "\"17. Seventeen\""), .value(description: "1")),
            .init(.value(description: "\"2.0\""), .value(description: "1")),
            .init(.value(description: "\"2. Two\""), .value(description: "1")),
            .init(.value(description: "\"1. One\""), .value(description: "1")),
            .init(.value(description: "\"  7\""), .value(description: "1"))
        ]

        let limn = Limn(of: testDictionary)

        XCTAssertEqualLimns(
            limn.sorted(order: .descending, options: [.numeric]),
            .dictionary(keyValuePairs: expectedNumericDescendingOrderKeyValuePairs)
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .ascending, options: [.numeric]),
            .dictionary(keyValuePairs: expectedNumericDescendingOrderKeyValuePairs.reversed())
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .descending, options: []),
            .dictionary(keyValuePairs: expectedDefaultDescendingOrderKeyValuePairs)
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .ascending, options: []),
            .dictionary(keyValuePairs: expectedDefaultDescendingOrderKeyValuePairs.reversed())
        )
    }

    func testSetElementsSorting() {

        let testSet = Set<AnyHashable>([
            8,
            "value",
            2,
            "2. Two",
            "17. Seventeen",
            "1. One",
            "  7",
            4.0,
            22,
            "2.0"
        ])

        let expectedDefaultDescendingOrderElements: [Limn] = [
            .value(description: "8"),
            .value(description: "4.0"),
            .value(description: "22"),
            .value(description: "2"),
            .value(description: "\"value\""),
            .value(description: "\"2.0\""),
            .value(description: "\"2. Two\""),
            .value(description: "\"17. Seventeen\""),
            .value(description: "\"1. One\""),
            .value(description: "\"  7\"")
        ]
        let expectedNumericalDescendingOrderElements: [Limn] = [
            .value(description: "22"),
            .value(description: "8"),
            .value(description: "4.0"),
            .value(description: "2"),
            .value(description: "\"value\""),
            .value(description: "\"17. Seventeen\""),
            .value(description: "\"2.0\""),
            .value(description: "\"2. Two\""),
            .value(description: "\"1. One\""),
            .value(description: "\"  7\"")
        ]

        let limn = Limn(of: testSet)

        XCTAssertEqualLimns(
            limn.sorted(order: .descending, options: [.numeric]),
            .set(elements: expectedNumericalDescendingOrderElements)
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .ascending, options: [.numeric]),
            .set(elements: expectedNumericalDescendingOrderElements.reversed())
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .descending, options: []),
            .set(elements: expectedDefaultDescendingOrderElements)
        )
        XCTAssertEqualLimns(
            limn.sorted(order: .ascending, options: []),
            .set(elements: expectedDefaultDescendingOrderElements.reversed())
        )
    }
}
