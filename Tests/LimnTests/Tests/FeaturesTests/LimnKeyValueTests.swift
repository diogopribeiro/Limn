import XCTest
@testable import Limn

final class LimnKeyValueTests: XCTestCase {

    func testKeyValueFromClass() {

        XCTAssertEqualLimns(
            SwiftClass.complex.expectedLimn["privateProperty"],
            .value(description: "77")
        )

        XCTAssertEqualLimns(
            SwiftClass.complex.expectedLimn["collectionProperty"][0][1],
            .value(description: "\"secondElement\"")
        )

        XCTAssertEqualLimns(
            SwiftClass.complex.expectedLimn["dictionaryProperty"][333.0],
            SwiftDictionary.simpleIntIntDictionary.expectedLimn
        )

        XCTAssertEqualLimns(
            SwiftClass.complex.expectedLimn["enumProperty"][0],
            .value(description: "\"mySecondCaseValue\"")
        )

        XCTAssertEqualLimns(
            SwiftClass.complex.expectedLimn["tupleProperty"]["afterSecondLabel"],
            .value(description: "3.0")
        )

        XCTAssertEqualLimns(
            SwiftClass.complex.expectedLimn["tupleProperty"][2],
            .value(description: "3.0")
        )
    }

    func testKeyValueFromEnum() {

        XCTAssertEqualLimns(
            SwiftEnum.complexEnum_secondCase.expectedLimn[0],
            .optional(value: SwiftEnum.complexEnum_firstCase.expectedLimn)
        )

        XCTAssertEqualLimns(
            SwiftEnum.complexEnum_secondCase.expectedLimn[1],
            .collection(elements: [
                .value(description: "\"Hello\""),
                .value(description: "\"World!\"")
            ])
        )

        XCTAssertEqualLimns(
            SwiftEnum.complexEnum_secondCase.expectedLimn["secondLabel"],
            .collection(elements: [
                .value(description: "\"Hello\""),
                .value(description: "\"World!\"")
            ])
        )

        XCTAssertEqualLimns(
            SwiftEnum.complexEnum_secondCase.expectedLimn["secondLabel"][1],
            .value(description: "\"World!\"")
        )
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    func testKeyValueOnDiffedLimns() {

        let modelBefore = SwiftCollection.simple2DStringsArray.instance
        var modelAfter = modelBefore
        modelAfter[0] = Array(modelAfter[0].dropFirst())
        modelAfter.append(["New Element"])
        let limn = Limn(of: modelBefore).diffed(to: modelAfter)

        XCTAssertEqualLimns(
            limn[0],
            .collection(elements: [
                Limn.Diff(original: .value(description: "\"firstElement\""), update: nil).limnValue,
                .value(description: "\"secondElement\""),
                .value(description: "\"thirdElement\""),
                .value(description: "\"fourthElement\"")
            ])
        )

        XCTAssertEqualLimns(
            limn[2][0],
            Limn.Diff(original: nil, update: .value(description: "\"New Element\"")).limnValue
        )
    }
}
