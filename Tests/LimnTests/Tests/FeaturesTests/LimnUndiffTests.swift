import Combine
import XCTest
@testable import Limn

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
class LimnUndiffTests: XCTestCase {

    func testClassUndiff() {

        let modelA = SwiftClass.Simple()
        let modelB = SwiftClass.Simple()
        let modelALimn = Limn(of: modelA)
        var modelBLimn = Limn(of: modelB)

        XCTAssertEqualLimns(
            modelALimn.diffed(to: modelBLimn).undiffed(to: .original),
            modelALimn
        )

        XCTAssertEqualLimns(
            modelALimn.diffed(to: modelBLimn).undiffed(to: .update),
            modelBLimn
        )

        modelB.firstProperty += 1
        modelB.secondProperty = "Updated"
        modelBLimn = Limn(of: modelB)

        XCTAssertNotEqual(
            modelALimn,
            modelBLimn
        )

        XCTAssertEqualLimns(
            modelALimn.diffed(to: modelBLimn).undiffed(to: .original),
            modelALimn
        )

        XCTAssertEqualLimns(
            modelALimn.diffed(to: modelBLimn).undiffed(to: .update),
            modelBLimn
        )
    }

    func testClassComplexUndiff() {

        let modelA = SwiftClass.Complex<Int, Set<Int>>()
        let modelB = SwiftClass.Complex<Int64, Array<Float>>()
        modelB.collectionProperty.append(["ADDED", "NEW"])
        modelB.enumProperty = .firstCase
        modelB.optionalNoneProperty = ["new": "added"]
        modelB.structProperty.secondProperty = "Changed property!"
        modelB.tupleProperty.3.toggle()

        let modelALimn = Limn(of: modelA).sorted()
        let modelBLimn = Limn(of: modelB).sorted()
        let diff = modelALimn.diffed(to: modelBLimn)

        XCTAssertTrue(diff.containsDiff)
        XCTAssertEqualLimns(diff.undiffed(to: .original)!.sorted(), modelALimn)
        XCTAssertEqualLimns(diff.undiffed(to: .update)!.sorted(), modelBLimn)
    }

    // TODO: Test remaining use cases
}
