import Limn

// MARK: - Type value descriptions

enum SwiftValue {

    static let expressibleByNilLiteralTypeValue: TestModel<ExpressibleByNilLiteral.Protocol> = (
        ExpressibleByNilLiteral.self,
        .value(description: "Swift.ExpressibleByNilLiteral.Protocol")
    )

    static let stringTypeValue: TestModel<String.Type> = (
        String.self,
        .value(description: "Swift.String.Type")
    )

    static let closureTypeValue: TestModel<(() -> Float).Type> = (
        (() -> Float).self,
        .value(description: "(() -> Swift.Float).Type")
    )

    // MARK: - Value descriptions

    static let stringValue: TestModel<String> = (
        "Hello\nWorld!",
        .value(description: "\"Hello\\nWorld!\"")
    )

    static let substringValue: TestModel<Substring> = (
        "Hello World!".dropLast(1),
        .value(description: "\"Hello World\"")
    )

    static let intValue: TestModel<Int> = (
        1,
        .value(description: "1")
    )
}
