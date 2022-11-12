import XCTest
@testable import Limn

final class CustomLimnRepresentableTests: XCTestCase {

    func testCustomClass() {
        test(SwiftClass.simpleCustomized)
    }

    // MARK: - Private methods

    private func test<T>(_ model: TestModel<T>) {
        let modelLimn = Limn(of: model.instance, maxDepth: .max)
        XCTAssertEqualLimns(modelLimn, model.expectedLimn)
    }
}
