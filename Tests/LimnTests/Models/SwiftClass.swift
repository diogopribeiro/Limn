import Combine
import Limn

enum SwiftClass {

    // MARK: - Empty classes

    class Empty {}
    private static let emptyInstance = Empty()
    static let empty: TestModel<Empty> = (
        emptyInstance,
        .class(
            name: "LimnTests.SwiftClass.Empty",
            address: Limn.address(of: emptyInstance),
            properties: []
        )
    )

    // MARK: - Simple classes

    class Simple {
        var firstProperty = 77
        var secondProperty = "Hello world!"
    }
    private static let simpleInstance = Simple()
    static let simpleInstanceAddress = Limn.address(of: simpleInstance)
    static let simple: TestModel<Simple> = (
        simpleInstance,
        .class(
            name: "LimnTests.SwiftClass.Simple",
            address: simpleInstanceAddress,
            properties: [
                .init("firstProperty", .value(description: "77")),
                .init("secondProperty", .value(description: "\"Hello world!\""))
            ]
        )
    )

    class SimpleSubclass: Simple {
        let thirdProperty = 3.14
    }
    private static let simpleSubclassInstance = SimpleSubclass()
    static let simpleSubclass: TestModel<SimpleSubclass> = (
        simpleSubclassInstance,
        .class(
            name: "LimnTests.SwiftClass.SimpleSubclass",
            address: Limn.address(of: simpleSubclassInstance),
            properties: [
                .init("firstProperty", .value(description: "77")),
                .init("secondProperty", .value(description: "\"Hello world!\"")),
                .init("thirdProperty", .value(description: "3.14"))
            ]
        )
    )

    final class SimpleSubSubclass: SimpleSubclass {
        let fourthProperty = true
    }
    private static let simpleSubSubclassInstance = SimpleSubSubclass()
    static let simpleSubSubclass: TestModel<SimpleSubSubclass> = (
        simpleSubSubclassInstance,
        .class(
            name: "LimnTests.SwiftClass.SimpleSubSubclass",
            address: Limn.address(of: simpleSubSubclassInstance),
            properties: [
                .init("firstProperty", .value(description: "77")),
                .init("secondProperty", .value(description: "\"Hello world!\"")),
                .init("thirdProperty", .value(description: "3.14")),
                .init("fourthProperty", .value(description: "true"))
            ]
        )
    )

    // MARK: - Complex classes

    final class Complex<X: ExpressibleByIntegerLiteral, Y: Collection>: Simple {

        private var privateProperty: X = 77
        lazy var lazyProperty = firstProperty

        var collectionProperty = SwiftCollection.simple2DStringsArray.instance
        var dictionaryProperty = SwiftDictionary.simpleAnyHashableDictionary.instance
        var enumProperty = SwiftEnum.simpleWithAssociatedType_secondCase.instance
        var optionalSomeProperty = SwiftOptional.someStringOptional.instance
        var optionalNoneProperty = SwiftOptional.noneDictionaryOptional.instance
        var setProperty = SwiftSet.simpleIntSet.instance
        var structProperty = SwiftStruct.simple.instance
        var tupleProperty = SwiftTuple.simpleSemiLabeled.instance
    }
    private static let complexInstance = Complex<Int, Array<String>>()
    static let complex: TestModel<Complex<Int, Array<String>>> = (
        complexInstance,
        .class(
            name: "LimnTests.SwiftClass.Complex<Swift.Int, Swift.Array<Swift.String>>",
            address: Limn.address(of: complexInstance),
            properties: [
                .init("firstProperty", .value(description: "77")),
                .init("secondProperty", .value(description: "\"Hello world!\"")),

                .init("privateProperty", .value(description: "77")),
                .init("lazyProperty", .optional(value: nil)),

                .init("collectionProperty", SwiftCollection.simple2DStringsArray.expectedLimn),
                .init("dictionaryProperty", SwiftDictionary.simpleAnyHashableDictionary.expectedLimn),
                .init("enumProperty", SwiftEnum.simpleWithAssociatedType_secondCase.expectedLimn),
                .init("optionalSomeProperty", SwiftOptional.someStringOptional.expectedLimn),
                .init("optionalNoneProperty", SwiftOptional.noneDictionaryOptional.expectedLimn),
                .init("setProperty", SwiftSet.simpleIntSet.expectedLimn),
                .init("structProperty", SwiftStruct.simple.expectedLimn),
                .init("tupleProperty", SwiftTuple.simpleSemiLabeled.expectedLimn),
            ]
        )
    )

    // MARK: - Diffed classes

    static let diffedComplexInstance_before = Complex<Int, Set<Float>>()
    static let diffedComplexInstance_after = {

        let instance = Complex<Float, Set<String>>()
        instance.collectionProperty = instance.collectionProperty.dropLast()
        instance.optionalSomeProperty = "new"
        instance.structProperty.fourthProperty.toggle()

        return instance
    }()
}

// MARK: - Customized classes

extension SwiftClass {

    class SimpleCustomized {
        var firstProperty = 77
        var secondProperty = "Hello world!"
    }
    private static let simpleCustomizedInstance = SimpleCustomized()
    static let simpleCustomizedInstanceAddress = Limn.address(of: simpleCustomizedInstance)
    static let simpleCustomized: TestModel<SimpleCustomized> = (
        simpleCustomizedInstance,
        .class(
            name: "LimnTests.SwiftClass.Customized.Simple",
            address: simpleCustomizedInstanceAddress,
            properties: [
                .init("firstProperty", .value(description: "78")),
                .init("secondProperty", .value(description: "\"Hello world!\""))
            ]
        )
    )
}

extension SwiftClass.SimpleCustomized: CustomLimnRepresentable {

    static var customLimnTypeName: String {
        "LimnTests.SwiftClass.Customized.Simple.Type"
    }

    func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        .class(
            name: Limn.typeName(of: self),
            address: Limn.address(of: self),
            properties: [
                .init("firstProperty", .value(description: "78")),
                .init("secondProperty", .value(description: "\"Hello world!\""))
            ]
        )
    }
}
