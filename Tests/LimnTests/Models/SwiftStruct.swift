import Limn

enum SwiftStruct {

    // MARK: - Empty structs

    struct Empty {}
    static let empty: TestModel<Empty> = (
        Empty(),
        .struct(
            name: "LimnTests.SwiftStruct.Empty",
            properties: []
        )
    )

    // MARK: - Simple classes

    struct Simple {
        var firstProperty = 77
        var secondProperty = "Hello world!"
        var thirdProperty = 3.14
        var fourthProperty = false
    }
    static let simple: TestModel<Simple> = (
        Simple(),
        .struct(
            name: "LimnTests.SwiftStruct.Simple",
            properties: [
                .init("firstProperty", .value(description: "77")),
                .init("secondProperty", .value(description: "\"Hello world!\"")),
                .init("thirdProperty", .value(description: "3.14")),
                .init("fourthProperty", .value(description: "false"))
            ]
        )
    )
}
