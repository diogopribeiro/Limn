import Foundation
import Limn

enum ObjCClass {

    // MARK: - Empty classes

    class Empty: NSObject {}
    private static let emptyInstance = Empty()
    static let empty: TestModel<Empty> = (
        emptyInstance,
        .class(
            name: "LimnTests.ObjCClass.Empty",
            address: Limn.address(of: emptyInstance),
            properties: []
        )
    )

    // MARK: - Simple classes

    class Simple: NSObject {
        var firstProperty = 77
        var secondProperty = "Hello world!"
    }
    private static let simpleInstance = Simple()
    static let simpleInstanceAddress = Limn.address(of: simpleInstance)
    static let simple: TestModel<Simple> = (
        simpleInstance,
        .class(
            name: "LimnTests.ObjCClass.Simple",
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
            name: "LimnTests.ObjCClass.SimpleSubclass",
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
            name: "LimnTests.ObjCClass.SimpleSubSubclass",
            address: Limn.address(of: simpleSubSubclassInstance),
            properties: [
                .init("firstProperty", .value(description: "77")),
                .init("secondProperty", .value(description: "\"Hello world!\"")),
                .init("thirdProperty", .value(description: "3.14")),
                .init("fourthProperty", .value(description: "true"))
            ]
        )
    )

    private static let simpleClassClusterInstance = NSURL(string: "http://foo.com")!
    static let simpleClassCluster: TestModel<NSURL> = (
        simpleClassClusterInstance,
        .class(
            name: "Foundation.NSURL",
            address: Limn.address(of: simpleClassClusterInstance),
            properties: [
                .init("_baseURL", .optional(value: nil)),
                .init("_urlString", .value(description: "\"http://foo.com\""))
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
            name: "LimnTests.ObjCClass.Complex<Swift.Int, Swift.Array<Swift.String>>",
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
}
