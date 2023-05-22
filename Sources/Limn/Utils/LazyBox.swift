final class LazyBox<T> {

    private var instance: T?
    private let makeInstance: () -> T

    init(_ makeInstance: @escaping () -> T) {
        self.makeInstance = makeInstance
    }

    var value: T {

        instance ?? {
            let newInstance = makeInstance()
            instance = newInstance
            return newInstance
        }()
    }
}
