import XCTest
@testable import Limn

final class LimnFilterTests: XCTestCase {
    
    func testDisplayStyleFilter() {
        
        final class TestContainer {
            let myClass = SwiftClass.simple.instance
            let myCollection = SwiftCollection.simpleIntArray.instance
            let myDictionary = SwiftDictionary.simpleIntIntDictionary.instance
            let myEnum = SwiftEnum.simple_firstCase.instance
            let myOptional = SwiftOptional.someStringOptional.instance
            let mySet = SwiftSet.simpleIntSet.instance
            let myStruct = SwiftStruct.simple.instance
            let myTuple = SwiftTuple.simpleUnlabeled.instance
            let myValue = SwiftValue.stringValue.instance
        }
        
        let instance = TestContainer()
        let limn = Limn(of: instance, maxDepth: .max)
        
        XCTAssertEqualLimns(
            limn.filtered(displayStyle: .class),
            .class(
                name: Limn.typeName(of: instance),
                address: Limn.address(of: instance),
                properties: [
                    .init("myClass", .class(
                        name: Limn.typeName(of: SwiftClass.simple.instance),
                        address: Limn.address(of: SwiftClass.simple.instance),
                        properties: [
                            .omitted(label: "firstProperty", reason: .filtered),
                            .omitted(label: "secondProperty", reason: .filtered)
                        ]
                    )),
                    .omitted(label: "myCollection", reason: .filtered),
                    .omitted(label: "myDictionary", reason: .filtered),
                    .omitted(label: "myEnum", reason: .filtered),
                    .omitted(label: "myOptional", reason: .filtered),
                    .omitted(label: "mySet", reason: .filtered),
                    .omitted(label: "myStruct", reason: .filtered),
                    .omitted(label: "myTuple", reason: .filtered),
                    .omitted(label: "myValue", reason: .filtered)
                ]
            )
        )
        
        XCTAssertEqualLimns(
            limn.filtered(displayStyle: .collection, matchDepth: .max),
            .class(
                name: Limn.typeName(of: instance),
                address: Limn.address(of: instance),
                properties: [
                    .omitted(label: "myClass", reason: .filtered),
                    .init("myCollection", SwiftCollection.simpleIntArray.expectedLimn),
                    .omitted(label: "myDictionary", reason: .filtered),
                    .omitted(label: "myEnum", reason: .filtered),
                    .omitted(label: "myOptional", reason: .filtered),
                    .omitted(label: "mySet", reason: .filtered),
                    .omitted(label: "myStruct", reason: .filtered),
                    .omitted(label: "myTuple", reason: .filtered),
                    .omitted(label: "myValue", reason: .filtered)
                ]
            )
        )
        
        XCTAssertEqualLimns(
            limn.filtered(displayStyle: .dictionary, matchDepth: .max),
            .class(
                name: Limn.typeName(of: instance),
                address: Limn.address(of: instance),
                properties: [
                    .omitted(label: "myClass", reason: .filtered),
                    .omitted(label: "myCollection", reason: .filtered),
                    .init("myDictionary", SwiftDictionary.simpleIntIntDictionary.expectedLimn),
                    .omitted(label: "myEnum", reason: .filtered),
                    .omitted(label: "myOptional", reason: .filtered),
                    .omitted(label: "mySet", reason: .filtered),
                    .omitted(label: "myStruct", reason: .filtered),
                    .omitted(label: "myTuple", reason: .filtered),
                    .omitted(label: "myValue", reason: .filtered)
                ]
            )
        )
        
        XCTAssertEqualLimns(
            limn.filtered(displayStyle: .enum, matchDepth: .max),
            .class(
                name: Limn.typeName(of: instance),
                address: Limn.address(of: instance),
                properties: [
                    .omitted(label: "myClass", reason: .filtered),
                    .omitted(label: "myCollection", reason: .filtered),
                    .omitted(label: "myDictionary", reason: .filtered),
                    .init("myEnum", SwiftEnum.simple_firstCase.expectedLimn),
                    .omitted(label: "myOptional", reason: .filtered),
                    .omitted(label: "mySet", reason: .filtered),
                    .omitted(label: "myStruct", reason: .filtered),
                    .omitted(label: "myTuple", reason: .filtered),
                    .omitted(label: "myValue", reason: .filtered)
                ]
            )
        )
        
        XCTAssertEqualLimns(
            limn.filtered(displayStyle: .optional, matchDepth: .max),
            .class(
                name: Limn.typeName(of: instance),
                address: Limn.address(of: instance),
                properties: [
                    .omitted(label: "myClass", reason: .filtered),
                    .omitted(label: "myCollection", reason: .filtered),
                    .omitted(label: "myDictionary", reason: .filtered),
                    .omitted(label: "myEnum", reason: .filtered),
                    .init("myOptional", SwiftOptional.someStringOptional.expectedLimn),
                    .omitted(label: "mySet", reason: .filtered),
                    .omitted(label: "myStruct", reason: .filtered),
                    .omitted(label: "myTuple", reason: .filtered),
                    .omitted(label: "myValue", reason: .filtered)
                ]
            )
        )
        
        XCTAssertEqualLimns(
            limn.filtered(displayStyle: .set, matchDepth: .max),
            .class(
                name: Limn.typeName(of: instance),
                address: Limn.address(of: instance),
                properties: [
                    .omitted(label: "myClass", reason: .filtered),
                    .omitted(label: "myCollection", reason: .filtered),
                    .omitted(label: "myDictionary", reason: .filtered),
                    .omitted(label: "myEnum", reason: .filtered),
                    .omitted(label: "myOptional", reason: .filtered),
                    .init("mySet", SwiftSet.simpleIntSet.expectedLimn),
                    .omitted(label: "myStruct", reason: .filtered),
                    .omitted(label: "myTuple", reason: .filtered),
                    .omitted(label: "myValue", reason: .filtered)
                ]
            )
        )
        
        XCTAssertEqualLimns(
            limn.filtered(displayStyle: .struct, matchDepth: .max),
            .class(
                name: Limn.typeName(of: instance),
                address: Limn.address(of: instance),
                properties: [
                    .omitted(label: "myClass", reason: .filtered),
                    .omitted(label: "myCollection", reason: .filtered),
                    .omitted(label: "myDictionary", reason: .filtered),
                    .omitted(label: "myEnum", reason: .filtered),
                    .omitted(label: "myOptional", reason: .filtered),
                    .omitted(label: "mySet", reason: .filtered),
                    .init("myStruct", SwiftStruct.simple.expectedLimn),
                    .omitted(label: "myTuple", reason: .filtered),
                    .omitted(label: "myValue", reason: .filtered)
                ]
            )
        )
        
        XCTAssertEqualLimns(
            limn.filtered(displayStyle: .tuple, matchDepth: .max),
            .class(
                name: Limn.typeName(of: instance),
                address: Limn.address(of: instance),
                properties: [
                    .omitted(label: "myClass", reason: .filtered),
                    .omitted(label: "myCollection", reason: .filtered),
                    .omitted(label: "myDictionary", reason: .filtered),
                    .omitted(label: "myEnum", reason: .filtered),
                    .omitted(label: "myOptional", reason: .filtered),
                    .omitted(label: "mySet", reason: .filtered),
                    .omitted(label: "myStruct", reason: .filtered),
                    .init("myTuple", SwiftTuple.simpleUnlabeled.expectedLimn),
                    .omitted(label: "myValue", reason: .filtered)
                ]
            )
        )
        
        XCTAssertEqualLimns(
            limn.filtered(displayStyle: .value, matchDepth: .max),
            .class(
                name: Limn.typeName(of: instance),
                address: Limn.address(of: instance),
                properties: [
                    .init("myClass", SwiftClass.simple.expectedLimn),
                    .init("myCollection", SwiftCollection.simpleIntArray.expectedLimn),
                    .init("myDictionary", SwiftDictionary.simpleIntIntDictionary.expectedLimn),
                    .init("myEnum", SwiftEnum.simple_firstCase.expectedLimn),
                    .init("myOptional", SwiftOptional.someStringOptional.expectedLimn),
                    .init("mySet", SwiftSet.simpleIntSet.expectedLimn),
                    .init("myStruct", SwiftStruct.simple.expectedLimn),
                    .init("myTuple", SwiftTuple.simpleUnlabeled.expectedLimn),
                    .init("myValue", SwiftValue.stringValue.expectedLimn)
                ]
            )
        )
    }

    func testValueFilter() {
        
        let classModel = SwiftClass.simple.instance

        XCTAssertEqualLimns(
            Limn(of: classModel).filtered(value: "world"),
            .omitted(reason: .filtered)
        )

        XCTAssertEqualLimns(
            Limn(of: classModel).filtered(value: "world*"),
            .omitted(reason: .filtered)
        )

        XCTAssertEqualLimns(
            Limn(of: classModel).filtered(value: "*world"),
            .omitted(reason: .filtered)
        )

        XCTAssertEqualLimns(
            Limn(of: classModel).filtered(value: "*world*"),
            .class(
                name: Limn.typeName(of: classModel),
                address: Limn.address(of: classModel),
                properties: [
                    .omitted(label: "firstProperty", reason: .filtered),
                    .init("secondProperty", .value(description: "\"Hello world!\""))
                ]
            )
        )

        XCTAssertEqualLimns(
            Limn(of: classModel).filtered(value: "77"),
            .class(
                name: Limn.typeName(of: classModel),
                address: Limn.address(of: classModel),
                properties: [
                    .init("firstProperty", .value(description: "77")),
                    .omitted(label: "secondProperty", reason: .filtered)
                ]
            )
        )
    }
}
