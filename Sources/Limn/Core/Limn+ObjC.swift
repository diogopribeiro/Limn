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
        self = Self.decode(value: value)
    }

    // MARK: - Helpers

    private static func decode(
        objCBitFieldWithPointer pointer: UnsafeMutableRawPointer,
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
        objCClassWithPointer pointer: UnsafeMutableRawPointer,
        typeEncoding: String,
        context: InitContext
    ) -> (value: Limn, readBytes: Int) {

        // TODO: Decode object

//        let className = String(typeEncoding.dropFirst(2).dropLast())
//        let classType: AnyClass = NSClassFromString(className)!
//        let readBytes = MemoryLayout.stride(ofValue: classType)

        return (.omitted(reason: .unresolved), 8)
    }

    private static func decode(
        objCCollectionWithPointer pointer: UnsafeMutableRawPointer,
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
        objCStructWithPointer pointer: UnsafeMutableRawPointer,
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
        objCValueWithPointer pointer: UnsafeMutableRawPointer,
        typeEncoding: String,
        context: InitContext
    ) -> (value: Limn, readBytes: Int) {

        func loadValue<T>(as: T.Type) -> (value: Limn, readBytes: Int) {

            let alignedPointer = pointer.alignedUp(for: T.self)
            let value = alignedPointer.load(as: T.self)
            let readBytes = MemoryLayout<T>.stride + (alignedPointer - pointer)
            return (.value(description: "\(value)"), readBytes)
        }

        switch typeEncoding {

        case "B": return loadValue(as: CBool.self)
        case "c": return loadValue(as: CChar.self)
        case "C": return loadValue(as: CUnsignedChar.self)
        case "d": return loadValue(as: CDouble.self)
        case "f": return loadValue(as: CFloat.self)
        case "i": return loadValue(as: CInt.self)
        case "I": return loadValue(as: CUnsignedInt.self)
        case "l": return loadValue(as: CLong.self)
        case "L": return loadValue(as: CUnsignedLong.self)
        case "Q": return loadValue(as: CUnsignedLongLong.self)
        case "q": return loadValue(as: CLongLong.self)
        case "s": return loadValue(as: CShort.self)
        case "S": return loadValue(as: CUnsignedShort.self)

        case "^v":
            return loadValue(as: uintptr_t.self)

        case _ where typeEncoding.starts(with: "b"):
            return Self.decode(objCBitFieldWithPointer: pointer, typeEncoding: typeEncoding, context: context)

        case _ where typeEncoding.starts(with: "@"):
            return Self.decode(objCClassWithPointer: pointer, typeEncoding: typeEncoding, context: context)

        case _ where typeEncoding.starts(with: "["):
            return Self.decode(objCCollectionWithPointer: pointer, typeEncoding: typeEncoding, context: context)

        case _ where typeEncoding.starts(with: "{"):
            return Self.decode(objCStructWithPointer: pointer, typeEncoding: typeEncoding, context: context)

        default:
            // assertionFailure("Type encoding '\(typeEncoding)' not yet supported")
            let pointerOffset = MemoryLayout<uintptr_t>.stride
            return (.omitted(reason: .unresolved), pointerOffset)
        }
    }

    private static func decode(value: NSValue) -> Limn {

        let typeEncoding = String(cString: value.objCType)

        switch typeEncoding {
        case "q":
            var containedValue: CLongLong = 0
            value.getValue(&containedValue, size: MemoryLayout<CLongLong>.stride)
            return .value(description: "\(containedValue)")

        default:
            //assertionFailure("Type encoding '\(typeEncoding)' not yet supported")
            return .omitted(reason: .unresolved)
        }
    }
}
