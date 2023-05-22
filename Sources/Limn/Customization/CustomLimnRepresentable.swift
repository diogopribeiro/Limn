/// A type that explicitly supplies its own `Limn` value.
///
/// You can create a `Limn` for any type using the `Limn(of:)` initializer, but if you are not satisfied with the values
/// supplied for your type by default, you can make it conform to `CustomLimnRepresentable` and return a custom `Limn`.
public protocol CustomLimnRepresentable {

    /// The custom type name for this instance.
    ///
    /// The returned type name must be fully qualified and refer to the type (and not the instance)
    /// (e.g.: `UIKit.UIView.Type`, `Swift.Collection<Swift.String>.Protocol`).
    static var customLimnTypeName: String { get }

    /// The custom `Limn` for this instance.
    ///
    /// You can use the provided closure to obtain a `Limn` to use as the starting point for your customization, or
    /// simply ignore it and return a different value.
    ///
    /// **All type names passed to `Limn` must be fully qualified.** Use the provided helper function
    /// `Limn.typeName(of:)` to obtain the fully qualified name of an instance. You can also use the built-in function
    /// `Limn.address(of)` to obtain the memory address of an object.
    ///
    /// - Parameters:
    ///   - defaultLimn: A closure which will compute and return the default `Limn` for this instance.
    ///   - context: The `Limn` initialization context from which this method is being invoked from. Use this context to
    ///     retrieve the current and maximum depth and pass it to invocations for `Limn.init` on child elements inside
    ///     this method if you need to.
    /// - Returns: The custom `Limn` for this instance.
    func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn
}

public extension CustomLimnRepresentable {

    static var customLimnTypeName: String {
        String(reflecting: self)
    }

    func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {

        let limn = defaultLimn()

        switch limn {
        case .class(_, address: let address, properties: let properties):
            return .class(name: Limn.typeName(of: self), address: address, properties: properties)

        case .enum(_, caseName: let caseName, associatedValue: let associatedValue):
            return .enum(name: Limn.typeName(of: self), caseName: caseName, associatedValue: associatedValue)

        case .struct(_, properties: let properties):
            return .struct(name: Limn.typeName(of: self), properties: properties)

        case .collection,
             .dictionary,
             .optional,
             .set,
             .tuple,
             .value,
             .omitted:
            return limn
        }
    }
}
