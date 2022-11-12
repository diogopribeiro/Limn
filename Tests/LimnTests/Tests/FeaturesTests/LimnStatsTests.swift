import XCTest
@testable import Limn

final class LimnStatsTests: XCTestCase {

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    func testDiffedEntriesCountStat() {

        let modelBefore = SwiftClass.diffedComplexInstance_before
        let modelAfter = SwiftClass.diffedComplexInstance_after
        let modelLimn = Limn.diff(from: modelBefore, to: modelAfter)

        XCTAssertEqual(
            modelLimn.stats().diffedEntriesCount,
            5
        )
    }

    func testFilteredEntriesCountStat() {

        let modelA = (0..<100).map { $0 }

        XCTAssertEqual(
            Limn(of: modelA).filtered(value: "*0*").stats().filteredEntriesCount,
            90
        )
    }

    func testMaxDepthStat() {

        enum A: String { case a = "A" }
        class B { let b: A? = A.a }
        struct C { let c = B() }

        let tuple = (C(), C())
        let collection = [tuple]
        let dictionary = ["dictionary": collection]
        let optional = Optional(dictionary)

        XCTAssertEqual(Limn(of: optional, maxDepth: 1).stats().maxDepth, 1)
        XCTAssertEqual(Limn(of: optional, maxDepth: 2).stats().maxDepth, 2)
        XCTAssertEqual(Limn(of: optional, maxDepth: 3).stats().maxDepth, 3)
        XCTAssertEqual(Limn(of: optional, maxDepth: 4).stats().maxDepth, 4)
        XCTAssertEqual(Limn(of: optional, maxDepth: 5).stats().maxDepth, 5)
        XCTAssertEqual(Limn(of: optional, maxDepth: .max).stats().maxDepth, 6)
        XCTAssertEqual(Limn(of: dictionary, maxDepth: .max).stats().maxDepth, 6)

        XCTAssertEqual(Limn(of: SwiftClass.empty.instance, maxDepth: .max).stats().maxDepth, 1)
        XCTAssertEqual(Limn(of: SwiftClass.simple.instance, maxDepth: .max).stats().maxDepth, 2)
        XCTAssertEqual(Limn(of: SwiftCollection.simple2DStringsArray.instance, maxDepth: .max).stats().maxDepth, 3)
        XCTAssertEqual(Limn(of: SwiftDictionary.simpleIntIntDictionary.instance, maxDepth: .max).stats().maxDepth, 2)
        XCTAssertEqual(Limn(of: SwiftEnum.simple_firstCase.instance, maxDepth: .max).stats().maxDepth, 1)
        XCTAssertEqual(Limn(of: SwiftEnum.complexEnum_secondCase.instance, maxDepth: .max).stats().maxDepth, 4)
        XCTAssertEqual(Limn(of: SwiftOptional.noneStringOptional.instance, maxDepth: .max).stats().maxDepth, 1)
        XCTAssertEqual(Limn(of: SwiftOptional.someStringOptional.instance, maxDepth: .max).stats().maxDepth, 1)
        XCTAssertEqual(Limn(of: SwiftSet.empty.instance, maxDepth: .max).stats().maxDepth, 1)
        XCTAssertEqual(Limn(of: SwiftSet.simpleIntSet.instance, maxDepth: .max).stats().maxDepth, 2)
        XCTAssertEqual(Limn(of: SwiftStruct.empty.instance, maxDepth: .max).stats().maxDepth, 1)
        XCTAssertEqual(Limn(of: SwiftStruct.simple.instance, maxDepth: .max).stats().maxDepth, 2)
        XCTAssertEqual(Limn(of: SwiftTuple.empty.instance, maxDepth: .max).stats().maxDepth, 1)
        XCTAssertEqual(Limn(of: SwiftTuple.simpleSemiLabeled.instance, maxDepth: .max).stats().maxDepth, 2)
        XCTAssertEqual(Limn(of: SwiftValue.stringValue.instance, maxDepth: .max).stats().maxDepth, 1)
    }

    func testTypeNamesStat() {

        let typeNames = Limn(of: SwiftClass.complex.instance, maxDepth: .max).stats().typeNames
        XCTAssertEqual(typeNames.count, 3)
        XCTAssertTrue(typeNames.contains(where: { $0.contains("SwiftClass.Complex") }))
        XCTAssertTrue(typeNames.contains(where: { $0.contains("SwiftStruct.Simple") }))
        XCTAssertTrue(typeNames.contains(where: { $0.contains("SwiftEnum.SimpleWithAssociatedType") }))
    }

    func testUnresolvededEntriesCountStat() {

        // TODO: Finish
    }
}
