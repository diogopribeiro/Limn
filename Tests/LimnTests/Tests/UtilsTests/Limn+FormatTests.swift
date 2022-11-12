import XCTest
@testable import Limn

final class TypeNameFormatterTests: XCTestCase {

    func testIsFullyQualifiedTypeName() {

        XCTAssertFalse(Limn.isFullyQualifiedTypeName("String"))
        XCTAssertFalse(Limn.isFullyQualifiedTypeName("<AnyPublisher<Module.String, Never>>"))
        XCTAssertFalse(Limn.isFullyQualifiedTypeName("UI-View"))
        XCTAssertFalse(Limn.isFullyQualifiedTypeName("  String.Test"))
        XCTAssertFalse(Limn.isFullyQualifiedTypeName("Swift.String."))

        XCTAssertTrue(Limn.isFullyQualifiedTypeName("Swift.String"))
        XCTAssertTrue(Limn.isFullyQualifiedTypeName("Combine.AnyPublisher<Swift.String, Swift.Never>"))
        XCTAssertTrue(Limn.isFullyQualifiedTypeName("UIKit.UIControl.State"))
    }

    func testSimpleTypeName() {

        let simpleName = "MyCustomTypeName"

        XCTAssertEqual(
            Limn.format(typeName: simpleName, including: []),
            simpleName
        )

        XCTAssertEqual(
            Limn.format(typeName: simpleName, including: [.moduleName]),
            simpleName
        )
        XCTAssertEqual(
            Limn.format(typeName: simpleName, including: [.genericTypeParameterNames]),
            simpleName
        )
        XCTAssertEqual(
            Limn.format(typeName: simpleName, including: [.nestingTypeNames]),
            simpleName
        )

        XCTAssertEqual(
            Limn.format(typeName: simpleName, including: [.moduleName, .nestingTypeNames]),
            simpleName
        )
        XCTAssertEqual(
            Limn.format(typeName: simpleName, including: [.moduleName, .genericTypeParameterNames]),
            simpleName
        )
        XCTAssertEqual(
            Limn.format(typeName: simpleName, including: [.nestingTypeNames, .genericTypeParameterNames]),
            simpleName
        )

        XCTAssertEqual(
            Limn.format(typeName: simpleName, including: .all),
            simpleName
        )
    }

    func testComplexTypeName() {

        let complexName = "Module.(Unknown context at 0x213).Wrapped.String<Frame.Yo.Test<One, Two.Another>, SwiftUI.Sub.Main>"

        XCTAssertEqual(
            Limn.format(typeName: complexName, including: []),
            "String"
        )

        XCTAssertEqual(
            Limn.format(typeName: complexName, including: [.moduleName]),
            "Module.String"
        )
        XCTAssertEqual(
            Limn.format(typeName: complexName, including: [.genericTypeParameterNames]),
            "String<Test<One, Another>, Main>"
        )
        XCTAssertEqual(
            Limn.format(typeName: complexName, including: [.nestingTypeNames]),
            "(Unknown context at 0x213).Wrapped.String"
        )

        XCTAssertEqual(
            Limn.format(typeName: complexName, including: [.moduleName, .nestingTypeNames]),
            "Module.(Unknown context at 0x213).Wrapped.String"
        )
        XCTAssertEqual(
            Limn.format(typeName: complexName, including: [.moduleName, .genericTypeParameterNames]),
            "Module.String<Frame.Test<One, Two.Another>, SwiftUI.Main>"
        )
        XCTAssertEqual(
            Limn.format(typeName: complexName, including: [.nestingTypeNames, .genericTypeParameterNames]),
            "(Unknown context at 0x213).Wrapped.String<Yo.Test<One, Another>, Sub.Main>"
        )

        XCTAssertEqual(
            Limn.format(typeName: complexName, including: .all),
            complexName
        )
    }
}
