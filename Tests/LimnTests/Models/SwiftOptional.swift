import Limn

enum SwiftOptional {

    // MARK: - Empty optional

    static let noneStringOptional: TestModel<String?> = (
        nil as String?,
        .optional(value: nil)
    )

    static let noneDictionaryOptional: TestModel<[AnyHashable: AnyHashable]?> = (
        nil as [AnyHashable: AnyHashable]?,
        .optional(value: nil)
    )

    // MARK: - Optionals with values

    static let someStringOptional: TestModel<String?> = (
        "Hello world!" as String?,
        .optional(value: .value(description: "\"Hello world!\""))
    )

    static let someDictionaryOptional: TestModel<[AnyHashable: AnyHashable]?> = (
        SwiftDictionary.simpleAnyHashableDictionary.instance as [AnyHashable: AnyHashable]?,
        .optional(value: SwiftDictionary.simpleAnyHashableDictionary.expectedLimn)
    )
}
