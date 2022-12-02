import Foundation

extension Limn {

    public struct InitContext {

        public let currentDepth: Int
        public let maxDepth: Int
        public let parentClassAddresses: Set<String>

        func addingClassAddress(_ address: String) -> (duplicateFound: Bool, updatedContext: Self) {

            var newParentClassAddresses = parentClassAddresses
            let duplicateFound = !newParentClassAddresses.insert(address).inserted
            let updatedContext = Self(
                currentDepth: currentDepth,
                maxDepth: maxDepth,
                parentClassAddresses: newParentClassAddresses
            )

            return (duplicateFound, updatedContext)
        }

        var incrementingDepth: Self {
            .init(currentDepth: currentDepth + 1, maxDepth: maxDepth, parentClassAddresses: parentClassAddresses)
        }
    }

    // MARK: - Initialization

    init<V>(of value: V, mirror: Mirror? = nil, context: InitContext) {

        let defaultLimn = { () -> Limn in

            let mirror = mirror ?? Mirror(reflecting: value)

            switch mirror.displayStyle {
            case .class:
                return .init(ofClass: value, mirror: mirror, context: context)

            case .collection:
                return .init(ofCollection: value, mirror: mirror, context: context)

            case .dictionary:
                return .init(ofDictionary: value, mirror: mirror, context: context)

            case .enum:
                return .init(ofEnum: value, mirror: mirror, context: context)

            case .optional:
                return .init(ofOptional: value, mirror: mirror, context: context)

            case .set:
                return .init(ofSet: value, mirror: mirror, context: context)

            case .struct:
                return .init(ofStruct: value, mirror: mirror, context: context)

            case .tuple:
                return .init(ofTuple: value, mirror: mirror, context: context)

            case .none:
                return .init(ofValue: value, mirror: mirror, context: context)

            @unknown default:
                assertionFailure("Missing enum case implementation")
                return .omitted(reason: .unresolved)
            }
        }

        let customLimn = { () -> Limn? in

            guard let customLimnRepresentable = value as? CustomLimnRepresentable else {
                return nil
            }

            let lazyDefaultLimn = LazyBox(defaultLimn)
            let customLimn = customLimnRepresentable.customLimn(
                defaultLimn: lazyDefaultLimn.valueFromClosure,
                context: context
            )

            assert(
                (value is NSObject) || customLimn.nonFullyQualifiedTypeNames.isEmpty,
                "The following type names from CustomLimnRepresentable implementations are not fully qualified: " +
                "'\(customLimn.nonFullyQualifiedTypeNames.joined(separator: "', '"))'. Please make sure that all " +
                "type names are fully qualified."
            )

            return customLimn
        }

        self = customLimn() ?? defaultLimn()
    }

    init<V>(ofClass value: V, mirror: Mirror, context: InitContext) {

        guard context.currentDepth <= context.maxDepth else {
            self = .omitted(reason: .maxDepthExceeded)
            return
        }

        // Get all Obj-C properties through Objc's Runtime APIs and all Swift properties through the Mirror APIs:

        let name = Self.typeName(of: value)
        let address = Self.address(of: value as AnyObject)
        let swiftProperties = Self.allClassProperties(from: mirror)
        let objcProperties = (value as? NSObject).map(ObjCRuntime.ivars(for:))

        guard context.currentDepth != context.maxDepth else {

            let hasProperties = (!swiftProperties.isEmpty || objcProperties?.isEmpty == false)
            let properties: [LabeledLimn] = hasProperties ? [.omitted(reason: .maxDepthExceeded)] : []
            self = .class(name: name, address: address, properties: properties)
            return
        }

        let (duplicateClassFound, context) = context.addingClassAddress(address)
        guard !duplicateClassFound else {
            self = .class(name: name, address: address, properties: [.omitted(reason: .referenceCycleDetected)])
            return
        }

        if let value = value as? NSValue {
            self = .init(ofObjCValue: value, context: context)
            return
        }

        var properties = swiftProperties.map { child -> LabeledLimn in
            let label = Self.format(propertyName: child.label!)
            let value = Limn(of: child.value, context: context.incrementingDepth)
            return LabeledLimn(label, value)
        }

        if let objcProperties = objcProperties, let value = value as? NSObject {
            properties += objcProperties.map {
                let label = $0.name
                let value = Limn(ofObjCIVar: $0, value: value, context: context.incrementingDepth)
                return LabeledLimn(label, value)
            }
        }

        self = .class(name: name, address: address, properties: properties)
    }

    init<V>(ofCollection value: V, mirror: Mirror, context: InitContext) {

        guard context.currentDepth <= context.maxDepth else {
            self = .omitted(reason: .maxDepthExceeded)
            return
        }

        guard context.currentDepth != context.maxDepth else {
            self = .collection(elements: mirror.children.isEmpty ? [] : [.omitted(reason: .maxDepthExceeded)])
            return
        }

        let elements = mirror.children.map { child -> Limn in
            Limn(of: child.value, context: context.incrementingDepth)
        }

        self = .collection(elements: elements)
    }

    init<V>(ofDictionary value: V, mirror: Mirror, context: InitContext) {

        guard context.currentDepth <= context.maxDepth else {
            self = .omitted(reason: .maxDepthExceeded)
            return
        }

        guard context.currentDepth != context.maxDepth else {
            self = .dictionary(keyValuePairs: mirror.children.isEmpty ? [] : [.omitted(reason: .maxDepthExceeded)])
            return
        }

        let keyValuePairs = mirror.children.map { child -> KeyedLimn in
            let keyValuePairMirror = Mirror(reflecting: child.value).children
            let keyMirror = keyValuePairMirror[keyValuePairMirror.startIndex]
            let valueMirror = keyValuePairMirror[keyValuePairMirror.index(after: keyValuePairMirror.startIndex)]
            let key = Limn(of: keyMirror.value, context: context.incrementingDepth)
            let value = Limn(of: valueMirror.value, context: context.incrementingDepth)
            return KeyedLimn(key, value)
        }

        self = .dictionary(keyValuePairs: keyValuePairs)
    }

    init<V>(ofEnum value: V, mirror: Mirror, context: InitContext) {

        guard context.currentDepth <= context.maxDepth else {
            self = .omitted(reason: .maxDepthExceeded)
            return
        }

        let name = Self.typeName(of: value)
        let caseName = String("\(value)".prefix(while: { $0 != "(" }))

        guard context.currentDepth != context.maxDepth else {
            let associatedValue: Limn? = mirror.children.isEmpty ? nil : .omitted(reason: .maxDepthExceeded)
            self = .enum(name: name, caseName: caseName, associatedValue: associatedValue)
            return
        }

        let associatedValue = mirror.children.first.map { child -> Limn in
            let childMirror = Mirror(reflecting: child.value)
            let childContext = childMirror.displayStyle == .none ? context.incrementingDepth : context
            return Limn(of: child.value, mirror: childMirror, context: childContext)
        }

        self = .enum(name: name, caseName: caseName, associatedValue: associatedValue)
    }

    init<V>(ofOptional value: V, mirror: Mirror, context: InitContext) {

        guard context.currentDepth <= context.maxDepth else {
            self = .omitted(reason: .maxDepthExceeded)
            return
        }

        let value = (mirror.children.first?.value).map { child -> Limn in
            Limn(of: child, context: context)
        }

        self = .optional(value: value)
    }

    init<V>(ofSet value: V, mirror: Mirror, context: InitContext) {

        guard context.currentDepth <= context.maxDepth else {
            self = .omitted(reason: .maxDepthExceeded)
            return
        }

        guard context.currentDepth != context.maxDepth else {
            self = .set(elements: mirror.children.isEmpty ? [] : [.omitted(reason: .maxDepthExceeded)])
            return
        }

        let elements = mirror.children.map { child -> Limn in
            Limn(of: child.value, context: context.incrementingDepth)
        }

        self = .set(elements: elements)
    }

    init<V>(ofStruct value: V, mirror: Mirror, context: InitContext) {

        guard context.currentDepth <= context.maxDepth else {
            self = .omitted(reason: .maxDepthExceeded)
            return
        }

        let name = Self.typeName(of: value)

        guard context.currentDepth != context.maxDepth else {
            let properties: [LabeledLimn] = mirror.children.isEmpty ? [] : [.omitted(reason: .maxDepthExceeded)]
            self = .struct(name: name, properties: properties)
            return
        }

        let properties = mirror.children.map { child -> LabeledLimn in
            let label = Self.format(propertyName: child.label!)
            let value = Limn(of: child.value, context: context.incrementingDepth)
            return LabeledLimn(label, value)
        }

        self = .struct(name: name, properties: properties)
    }

    init<V>(ofTuple value: V, mirror: Mirror, context: InitContext) {

        guard context.currentDepth <= context.maxDepth else {
            self = .omitted(reason: .maxDepthExceeded)
            return
        }

        guard context.currentDepth != context.maxDepth else {
            self = .tuple(elements: mirror.children.isEmpty ? [] : [.omitted(reason: .maxDepthExceeded)])
            return
        }

        let elements = mirror.children.map { child -> LabeledLimn in
            let label = child.label!
            let value = Limn(of: child.value, context: context.incrementingDepth)
            return LabeledLimn(label, value)
        }

        self = .tuple(elements: elements)
    }

    init<V>(ofValue value: V, mirror: Mirror, context: InitContext) {

        guard context.currentDepth <= context.maxDepth else {
            self = .omitted(reason: .maxDepthExceeded)
            return
        }

        switch value {
        case is AnyHashable where mirror.children.count == 1:
            self = .init(of: mirror.children.first!.value, context: context)

        case is Any.Type,
             is Any.Protocol:
            self = .value(description: Self.typeName(of: value))

        default:
            self = .value(description: String(reflecting: value))
        }
    }
}
