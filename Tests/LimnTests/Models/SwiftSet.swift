import Limn

enum SwiftSet {

    // MARK: - Empty sets

    static let empty: TestModel<Set<AnyHashable>> = (
        Set<AnyHashable>([]),
        .set(elements: [])
    )

    // MARK: - Simple sets

    private static let simpleIntSetInstance: Set<Int> = .init([
        1,
        22,
        333,
        4444
    ])

    static let simpleIntSet: TestModel<Set<Int>> = (
        simpleIntSetInstance,
        .set(elements: arrayMatchingIterationOrder(of: simpleIntSetInstance, with: [
            1: .value(description: "1"),
            22: .value(description: "22"),
            333: .value(description: "333"),
            4444: .value(description: "4444")
        ]))
    )
}
