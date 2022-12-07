import XCTest
@testable import Limn

final class LimnObjCInitializationTests: XCTestCase {

    func testObjCClassInitialization() throws {

        test(ObjCClass.empty)
        test(ObjCClass.simple)
        test(ObjCClass.simpleSubclass)
        test(ObjCClass.simpleSubSubclass)
        test(ObjCClass.simpleClassCluster)
        test(ObjCClass.complex)
    }

    func testNSValueInitialization() throws {

        // TODO: Finish this test
    }

    func testObjCValueInitialization() {

        test(ObjCValue.viewTypeValue)
    }

    // MARK: - Private methods

    private func test<T>(_ model: TestModel<T>) {
        let modelLimn = Limn(of: model.instance, maxDepth: .max)
        XCTAssertEqualLimns(modelLimn, model.expectedLimn)
    }
}
