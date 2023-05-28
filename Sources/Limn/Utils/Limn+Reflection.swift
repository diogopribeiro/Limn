extension Limn {

    // MARK: - Public API

    /// Returns the fully qualified name of a Swift instance of any type.
    ///
    /// Besides the type name, this method will return the module name, type names of any nesting types and the fully
    /// qualified generic placeholder values.
    ///
    /// Bear in mind this method will not work as expected on Objective-C types by default due to limitations of this
    /// language.
    ///
    /// If you wish to change the default value, make your desired type conform to ``CustomLimnRepresentable`` and
    /// implement ``CustomLimnRepresentable/customLimnTypeName``.
    ///
    /// - Parameter value: The instance to get the type name of.
    /// - Returns: The fully qualified name of the given instance.
    public static func typeName(of value: Any) -> String {

        guard
            let customTypeName = (value as? any CustomLimnRepresentable.Type)?.customLimnTypeName ??
                (type(of: value) as? any CustomLimnRepresentable.Type)?.customLimnTypeName
        else {
            return String(reflecting: type(of: value))
        }

        if !(value is Any.Type) && !(value is Any.Protocol), let lastIndex = customTypeName.lastIndex(of: ".") {
            return String(customTypeName.prefix(upTo: lastIndex))
        } else {
            return customTypeName
        }
    }

    /// Returns the memory address of an object in hexadecimal format.
    ///
    /// - Parameter value: The object instance to get the address from.
    /// - Returns: The memory address of the given object in hexadecimal format (e.g., "0x600000fe4260")
    public static func address(of value: AnyObject) -> String {
        "0x" + String(describing: Unmanaged.passUnretained(value).toOpaque()).suffix(12)
    }

    // MARK: - Internal methods

    static func classProperties(from mirror: Mirror) -> [Mirror.Child] {

        guard mirror.displayStyle == .class else {
            assertionFailure()
            return []
        }

        var properties = [Mirror.Child]()
        var currentMirror: Mirror? = mirror

        while let currentMirrorUnwrapped = currentMirror {
            properties.insert(contentsOf: currentMirrorUnwrapped.children, at: 0)
            currentMirror = currentMirror?.superclassMirror
        }

        return properties
    }
}
