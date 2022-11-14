import Foundation

extension Limn {

    init(ofObjCIVar ivar: ObjCRuntime.IVar, value: NSObject, context: InitContext) {

        if ivar.typeEncoding.starts(with: "@") {

            self = .init(
                of: object_getIvar(value, ivar.ivar) as Any,
                context: context
            )

        } else {

            self = Self.decode(
                objCValueWithPointer: Unmanaged.passUnretained(value).toOpaque() + ivar.offset,
                typeEncoding: ivar.typeEncoding,
                context: context
            ).value
        }
    }

    init(ofObjCValue value: NSValue, context: InitContext) {
        self = Self.decode(nsValue: value)
    }

    // MARK: - Helpers

    private static func decode(nsValue: NSValue) -> Limn {

        func getValue<T>(using value: T) -> Limn {
            var valueCopy = value
            nsValue.getValue(&valueCopy, size: MemoryLayout<T>.stride)
            return .value(description: "\(valueCopy)")
        }

        let typeEncoding = String(cString: nsValue.objCType)

        switch typeEncoding {

        case "B": return getValue(using: false as CBool)
        case "c": return getValue(using: 0 as CChar)
        case "C": return getValue(using: 0 as CUnsignedChar)
        case "d": return getValue(using: 0 as CDouble)
        case "f": return getValue(using: 0 as CFloat)
        case "i": return getValue(using: 0 as CInt)
        case "I": return getValue(using: 0 as CUnsignedInt)
        case "l": return getValue(using: 0 as CLong)
        case "L": return getValue(using: 0 as CUnsignedLong)
        case "Q": return getValue(using: 0 as CUnsignedLongLong)
        case "q": return getValue(using: 0 as CLongLong)
        case "s": return getValue(using: 0 as CShort)
        case "S": return getValue(using: 0 as CUnsignedShort)

        default:
            // assertionFailure("Type encoding '\(typeEncoding)' not yet supported")
            return .omitted(reason: .unresolved)
        }
    }

    private static func decode(
        objCBitFieldWithPointer pointer: UnsafeRawPointer,
        typeEncoding: String,
        context: InitContext
    ) -> (value: Limn, readBytes: Int) {

        let bitFieldSize = Int(typeEncoding.dropFirst())!
        let readBytesDivision = bitFieldSize.quotientAndRemainder(dividingBy: 8)
        let readBytes = readBytesDivision.quotient + (readBytesDivision.remainder > 0 ? 1 : 0)

        switch readBytes {
        case 1:
            let value = pointer.load(as: CBool.self)
            return (.value(description: "\(value)"), readBytes)

        case 2:
            let valueBytes = pointer.load(as: (CChar, CChar).self)
            let value = CShort(valueBytes.0) + CShort(valueBytes.1) << 8
            return (.value(description: "\(String(value, radix: 2))"), readBytes)

        case 3:
            let valueBytes = pointer.load(as: (CChar, CChar, CChar).self)
            let value = CShort(valueBytes.0) + CShort(valueBytes.1) << 8 + CShort(valueBytes.2) << 16
            return (.value(description: "\(String(value, radix: 2))"), readBytes)

        case 4:
            let valueBytes = pointer.load(as: (CChar, CChar, CChar, CChar).self)
            let value = CShort(valueBytes.0) + CShort(valueBytes.1) << 8 +
                CShort(valueBytes.2) << 16 + CShort(valueBytes.3) << 24
            return (.value(description: "\(String(value, radix: 2))"), readBytes)

        default:
            assertionFailure()
            return (.omitted(reason: .unresolved), readBytes)
        }
    }

    private static func decode(
        objCClassWithPointer pointer: UnsafeRawPointer,
        typeEncoding: String,
        context: InitContext
    ) -> (value: Limn, readBytes: Int) {

        let alignedPointer = pointer.alignedUp(for: NSString.self)
        let value = alignedPointer.load(as: NSString.self)
        let readBytes = MemoryLayout<NSString>.stride + (alignedPointer - pointer)

        return (.value(description: "\(value).Type"), readBytes)
    }

    private static func decode(
        objCCollectionWithPointer pointer: UnsafeRawPointer,
        typeEncoding: String,
        context: InitContext
    ) -> (value: Limn, readBytes: Int) {

        var readBytes = 0
        let elementsCount = Int(typeEncoding.dropFirst().prefix(while: { $0.isNumber }))!
        let elementsTypeEncoding = String(typeEncoding.dropFirst(2).dropLast())
        let elements = (0..<elementsCount).map { _ -> Limn in
            let decodedElement = decode(
                objCValueWithPointer: pointer + readBytes,
                typeEncoding: elementsTypeEncoding,
                context: context.incrementingDepth
            )
            readBytes += decodedElement.readBytes
            return decodedElement.value
        }

        guard context.currentDepth <= context.maxDepth else {
            return (.omitted(reason: .maxDepthExceeded), readBytes)
        }

        guard context.currentDepth != context.maxDepth else {
            return (.collection(elements: elements.isEmpty ? [] : [.omitted(reason: .maxDepthExceeded)]), readBytes)
        }

        return (.collection(elements: elements), readBytes)
    }

    private static func decode(
        objCObjectWithPointer pointer: UnsafeRawPointer,
        typeEncoding: String,
        context: InitContext
    ) -> (value: Limn, readBytes: Int) {

        // TODO: Decoding of objects

//        let className = String(typeEncoding.dropFirst(2).dropLast())
//        let classType: AnyClass = NSClassFromString(className)!

        return (.omitted(reason: .unresolved), 8)
    }

    private static func decode(
        objCPointer pointer: UnsafeRawPointer,
        typeEncoding: String,
        context: InitContext
    ) -> (value: Limn, readBytes: Int) {

        let pointeeValue = pointer.alignedUp(for: uintptr_t.self).load(as: uintptr_t.self)
        guard pointeeValue != 0 else {
            return (.optional(value: nil), MemoryLayout<uintptr_t>.stride)
        }

        let pointee = UnsafeRawPointer(bitPattern: pointeeValue)!
        let pointeeTypeEncoding = String(typeEncoding.dropFirst())

        return decode(objCValueWithPointer: pointee, typeEncoding: pointeeTypeEncoding, context: context)
    }

    private static func decode(
        objCStructWithPointer pointer: UnsafeRawPointer,
        typeEncoding: String,
        context: InitContext
    ) -> (value: Limn, readBytes: Int) {

        var readBytes = 0
        let decodedType = ObjCRuntime.decodeStructTypeEncoding(typeEncoding)
        let properties = decodedType.components.map { component -> LabeledLimn in

            let propertyName = component.name
            let propertyType = component.typeEncoding
            let (propertyValue, propertyReadBytes) = Self.decode(
                objCValueWithPointer: pointer + readBytes,
                typeEncoding: propertyType,
                context: context.incrementingDepth
            )

            readBytes += propertyReadBytes

            return .init(propertyName, propertyValue)
        }

        guard context.currentDepth <= context.maxDepth else {
            return (.omitted(reason: .maxDepthExceeded), readBytes)
        }

        guard context.currentDepth != context.maxDepth else {
            let omittedProperties: [LabeledLimn] = properties.isEmpty ? [] : [.omitted(reason: .maxDepthExceeded)]
            return (.struct(name: decodedType.name, properties: omittedProperties), readBytes)
        }

        return (.struct(name: decodedType.name, properties: properties), readBytes)
    }

    private static func decode(
        objCUnionWithPointer pointer: UnsafeRawPointer,
        typeEncoding: String,
        context: InitContext
    ) -> (value: Limn, readBytes: Int) {

        // TODO: Finish this

        var readBytes = 0
        let decodedType = ObjCRuntime.decodeStructTypeEncoding(typeEncoding)
        let properties = decodedType.components.map { component -> LabeledLimn in

            let propertyName = component.name
            let propertyType = component.typeEncoding
            let (propertyValue, propertyReadBytes) = Self.decode(
                objCValueWithPointer: pointer + readBytes,
                typeEncoding: propertyType,
                context: context.incrementingDepth
            )

            readBytes += propertyReadBytes

            return .init(propertyName, propertyValue)
        }

        guard context.currentDepth <= context.maxDepth else {
            return (.omitted(reason: .maxDepthExceeded), readBytes)
        }

        guard context.currentDepth != context.maxDepth else {
            let omittedProperties: [LabeledLimn] = properties.isEmpty ? [] : [.omitted(reason: .maxDepthExceeded)]
            return (.struct(name: decodedType.name, properties: omittedProperties), readBytes)
        }

        return (.struct(name: decodedType.name, properties: properties), readBytes)
    }

    private static func decode(
        objCValueWithPointer pointer: UnsafeRawPointer,
        typeEncoding: String,
        context: InitContext
    ) -> (value: Limn, readBytes: Int) {

        func load<T>(as: T.Type) -> (value: Limn, readBytes: Int) {

            let alignedPointer = pointer.alignedUp(for: T.self)
            let value = alignedPointer.load(as: T.self)
            let readBytes = MemoryLayout<T>.stride + (alignedPointer - pointer)

            return (.value(description: "\(value)"), readBytes)
        }

        switch typeEncoding {

        case "B": return load(as: CBool.self)
        case "c": return load(as: CChar.self)
        case "C": return load(as: CUnsignedChar.self)
        case "d": return load(as: CDouble.self)
        case "f": return load(as: CFloat.self)
        case "i": return load(as: CInt.self)
        case "I": return load(as: CUnsignedInt.self)
        case "l": return load(as: CLong.self)
        case "L": return load(as: CUnsignedLong.self)
        case "Q": return load(as: CUnsignedLongLong.self)
        case "q": return load(as: CLongLong.self)
        case "s": return load(as: CShort.self)
        case "S": return load(as: CUnsignedShort.self)

        case "v":
            let address = String("\(pointer)").replacingOccurrences(of: "0x0000", with: "0x")
            return (.value(description: address), 8)

        case "#":
            return Self.decode(objCClassWithPointer: pointer, typeEncoding: typeEncoding, context: context)

        case _ where typeEncoding.starts(with: "^"):
            return Self.decode(objCPointer: pointer, typeEncoding: typeEncoding, context: context)

        case _ where typeEncoding.starts(with: "@"):
            return Self.decode(objCObjectWithPointer: pointer, typeEncoding: typeEncoding, context: context)

        case _ where typeEncoding.starts(with: "("):
            return Self.decode(objCUnionWithPointer: pointer, typeEncoding: typeEncoding, context: context)

        case _ where typeEncoding.starts(with: "["):
            return Self.decode(objCCollectionWithPointer: pointer, typeEncoding: typeEncoding, context: context)

        case _ where typeEncoding.starts(with: "{"):
            return Self.decode(objCStructWithPointer: pointer, typeEncoding: typeEncoding, context: context)

        case _ where typeEncoding.starts(with: "A"):
            let typeEncoding = String(typeEncoding.dropFirst())
            return Self.decode(objCValueWithPointer: pointer, typeEncoding: typeEncoding, context: context)

        case _ where typeEncoding.starts(with: "b"):
            return Self.decode(objCBitFieldWithPointer: pointer, typeEncoding: typeEncoding, context: context)

        default:
            assertionFailure("Type encoding '\(typeEncoding)' not yet supported")
            let pointerOffset = MemoryLayout<uintptr_t>.stride
            return (.omitted(reason: .unresolved), pointerOffset)
        }
    }
}
