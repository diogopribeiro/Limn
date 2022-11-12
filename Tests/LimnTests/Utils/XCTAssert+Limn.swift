import XCTest
@testable import Limn

func XCTAssertEqualLimns(_ limn: Limn?, _ expectedLimn: Limn?) {

    let dumpFormat = Limn.DumpFormat(typeNameComponents: .all)
    let limnDump = (limn?.stringDump(format: dumpFormat) ?? "nil").indented()
    let expectedLimnDump = (expectedLimn?.stringDump(format: dumpFormat) ?? "nil").indented()

    XCTAssert(
        expectedLimn == limn,
        ("\n\nExpected:\n\n\(expectedLimnDump)\n\n" +
         "Found:\n\n\(limnDump)\n").indented()
    )
}
