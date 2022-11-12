import XCTest
@testable import Limn

final class LimnStorageTests: XCTestCase {

    override class func setUp() {
        Limn.clearAll()
    }

    func testLimnStoreCRUDOperations() {

        let modelA = SwiftClass.complex.expectedLimn
        let modelB = SwiftDictionary.complexDictionary.expectedLimn

        XCTAssertNil(Limn.load(1))
        XCTAssertTrue(modelA.save(as: 1))
        XCTAssertEqualLimns(Limn.load(1), modelA)

        XCTAssertFalse(modelB.save(as: 1, overwrite: false))
        XCTAssertEqualLimns(Limn.load(1), modelA)

        XCTAssertTrue(modelB.save(as: 1, overwrite: true))
        XCTAssertEqualLimns(Limn.load(1), modelB)

        XCTAssertTrue(Limn.clear(1))
        XCTAssertFalse(Limn.clear(1))
        XCTAssertNil(Limn.load(1))
    }

    func testLimnStoreListOperation() {

        let modelA = SwiftClass.complex.expectedLimn
        let modelB = SwiftDictionary.complexDictionary.expectedLimn

        XCTAssertEqual(Limn.list(), [])

        XCTAssertTrue(modelA.save(as: 35))
        XCTAssertTrue(modelB.save(as: "Test Limn"))

        XCTAssertEqual(Limn.list(), ["Test Limn", "35"])
        XCTAssertEqual(Limn.clearAll(), 2)
    }
}
