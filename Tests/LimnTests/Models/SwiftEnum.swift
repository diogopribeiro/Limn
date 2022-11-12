import Limn

enum SwiftEnum {

    // MARK: - Empty enums

    enum Empty {}
    static let emptyType: TestModel<Empty.Type> = (
        Empty.self,
        .value(description: "LimnTests.SwiftEnum.Empty.Type")
    )

    // MARK: - Simple enums

    enum Simple {
        case firstCase
        case secondCase
    }
    static let simple_firstCase: TestModel<Simple> = (
        Simple.firstCase,
        .enum(
            name: "LimnTests.SwiftEnum.Simple",
            caseName: "firstCase",
            associatedValue: nil
        )
    )

    enum SimpleWithStringRawType: String {
        case firstCase = "firstCaseString"
        case secondCase = "secondCaseString"
    }
    static let simpleWithStringRawType_secondCase: TestModel<SimpleWithStringRawType> = (
        SimpleWithStringRawType.secondCase,
        .enum(
            name: "LimnTests.SwiftEnum.SimpleWithStringRawType",
            caseName: "secondCase",
            associatedValue: nil
        )
    )

    enum SimpleWithAssociatedType {
        case firstCase
        case secondCase(String)
        case thirdCase(String, Int)
        case fourthCase(_ firstLabel: String, secondLabel: Int)
    }
    static let simpleWithAssociatedType_firstCase: TestModel<SimpleWithAssociatedType> = (
        SimpleWithAssociatedType.firstCase,
        .enum(
            name: "LimnTests.SwiftEnum.SimpleWithAssociatedType",
            caseName: "firstCase",
            associatedValue: nil
        )
    )
    static let simpleWithAssociatedType_secondCase: TestModel<SimpleWithAssociatedType> = (
        SimpleWithAssociatedType.secondCase("mySecondCaseValue"),
        .enum(
            name: "LimnTests.SwiftEnum.SimpleWithAssociatedType",
            caseName: "secondCase",
            associatedValue: .value(description: "\"mySecondCaseValue\"")
        )
    )
    static let simpleWithAssociatedType_thirdCase: TestModel<SimpleWithAssociatedType> = (
        SimpleWithAssociatedType.thirdCase("myThirdCaseValue", 114),
        .enum(
            name: "LimnTests.SwiftEnum.SimpleWithAssociatedType",
            caseName: "thirdCase",
            associatedValue: .tuple(elements: [
                .init(".0", .value(description: "\"myThirdCaseValue\"")),
                .init(".1", .value(description: "114"))
            ])
        )
    )
    static let simpleWithAssociatedType_fourthCase: TestModel<SimpleWithAssociatedType> = (
        SimpleWithAssociatedType.fourthCase("mySecondCaseValue", secondLabel: 38),
        .enum(
            name: "LimnTests.SwiftEnum.SimpleWithAssociatedType",
            caseName: "fourthCase",
            associatedValue: .tuple(elements: [
                .init(".0", .value(description: "\"mySecondCaseValue\"")),
                .init("secondLabel", .value(description: "38"))
            ])
        )
    )

    // MARK: - Complex enums

    indirect enum ComplexEnum {
        case firstCase
        case secondCase((Self?, secondLabel: [String]))
        case thirdCase(firstLabel: SimpleWithAssociatedType, Set<Simple>)
        case fourthCase(dictionary: [Int: AnyHashable])
    }
    static let complexEnum_firstCase: TestModel<ComplexEnum> = (
        ComplexEnum.firstCase,
        .enum(
            name: "LimnTests.SwiftEnum.ComplexEnum",
            caseName: "firstCase",
            associatedValue: nil
        )
    )
    static let complexEnum_secondCase: TestModel<ComplexEnum> = (
        ComplexEnum.secondCase((.firstCase, secondLabel: ["Hello", "World!"])),
        .enum(
            name: "LimnTests.SwiftEnum.ComplexEnum",
            caseName: "secondCase",
            associatedValue: .tuple(elements: [
                .init(".0", .optional(value: complexEnum_firstCase.expectedLimn)),
                .init("secondLabel", .collection(elements: [
                    .value(description: "\"Hello\""),
                    .value(description: "\"World!\"")
                ]))
            ])
        )
    )
}
