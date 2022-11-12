import Limn

enum SwiftCollection {

    // MARK: - Empty collections

    static let empty: TestModel<[AnyHashable]> = (
        [],
        .collection(elements: [])
    )

    // MARK: - Simple collections

    static let simpleIntArray: TestModel<[Int]> = (
        [
            1,
            22,
            333,
            4444
        ],
        .collection(elements: [
            .value(description: "1"),
            .value(description: "22"),
            .value(description: "333"),
            .value(description: "4444")
        ])
    )

    static let simpleStringArray: TestModel<[String]> = (
        [
            "firstElement",
            "secondElement",
            "thirdElement",
            "fourthElement"
        ],
        .collection(elements: [
            .value(description: "\"firstElement\""),
            .value(description: "\"secondElement\""),
            .value(description: "\"thirdElement\""),
            .value(description: "\"fourthElement\"")
        ])
    )

    static let simple2DStringsArray: TestModel<[[String]]> = (
        [
            simpleStringArray.instance,
            [
                "Hello world!"
            ]
        ],
        .collection(elements: [
            simpleStringArray.expectedLimn,
            .collection(elements: [
                .value(description: "\"Hello world!\"")
            ])
        ])
    )

    static let simple3DAnyHashableArray: TestModel<[[[AnyHashable]]]> = (
        [
            simple2DStringsArray.instance,
            [
                simpleStringArray.instance,
                simpleIntArray.instance
            ]
        ],
        .collection(elements: [
            simple2DStringsArray.expectedLimn,
            .collection(elements: [
                simpleStringArray.expectedLimn,
                simpleIntArray.expectedLimn
            ])
        ])
    )
}
