import Foundation

enum ObjCRuntime {

    struct IVar {

        let ivar: Ivar
        let name: String
        let typeEncoding: String
        let offset: Int
    }

    struct TypeEncodingComponent {

        let name: String
        let typeEncoding: String
    }

    static func decodeStructTypeEncoding(
        _ typeEncoding: String
    ) -> (name: String, components: [TypeEncodingComponent]) {

        func decodeNestableType(start: Character, end: Character, encodedProperties: inout Substring) -> String {

            var nestableType = ""
            var nestingLevel = 0
            repeat {
                if encodedProperties.first == start { nestingLevel += 1 }
                else if encodedProperties.first == end { nestingLevel -= 1 }
                nestableType += String(encodedProperties.first!)
                encodedProperties = encodedProperties.dropFirst()
            } while nestingLevel > 0

            return nestableType
        }

        let typeName = typeEncoding
            .dropFirst()
            .prefix { $0 != "=" }
        var components = [TypeEncodingComponent]()

        var encodedProperties = typeEncoding.dropFirst(typeName.count + 2).dropLast()
        while !encodedProperties.isEmpty {

            let propertyName = String(encodedProperties.dropFirst().prefix(while: { $0 != "\"" }))
            let propertyTypeEncoding: String

            encodedProperties = encodedProperties.dropFirst(propertyName.count + 2)
            switch encodedProperties.first {
            case "{":
                propertyTypeEncoding = decodeNestableType(start: "{", end: "}", encodedProperties: &encodedProperties)

            case "@":
                let objectNameEndIndex = encodedProperties.dropFirst(2).firstIndex(of: "\"")!
                propertyTypeEncoding = String(encodedProperties[...objectNameEndIndex])
                encodedProperties = encodedProperties.dropFirst(propertyTypeEncoding.count)

            case "[":
                propertyTypeEncoding = decodeNestableType(start: "[", end: "]", encodedProperties: &encodedProperties)

            case "(":
                propertyTypeEncoding = decodeNestableType(start: "(", end: ")", encodedProperties: &encodedProperties)

            default:
                let endIndex = encodedProperties.firstIndex(of: "\"") ?? encodedProperties.endIndex
                propertyTypeEncoding = String(encodedProperties[..<endIndex])
                encodedProperties = encodedProperties[endIndex...]
            }

            let component = TypeEncodingComponent(name: propertyName, typeEncoding: propertyTypeEncoding)
            components.append(component)
        }

        return (String(typeName), components)
    }

    static func ivars(for value: NSObject) -> [IVar] {

        var ivars = [IVar]()

        var nextClass: AnyClass? = type(of: value)
        while let currentClass = nextClass {

            nextClass = currentClass.superclass()

            var ivarsCount: UInt32 = 0
            if let ivarsList = class_copyIvarList(currentClass, &ivarsCount), ivarsCount > 0 {

                ivars += (0..<ivarsCount)
                    .map { ivarsList[Int($0)] }
                    .compactMap { ivar in

                        guard
                            let ivarName = ivar_getName(ivar).map(String.init(cString:)),
                            let ivarEncoding = ivar_getTypeEncoding(ivar).map(String.init(cString:)),
                            !ivarEncoding.isEmpty && ivarName != "isa" // Skip Swift properties and ISA pointers.
                        else {
                            return nil
                        }

                        return .init(
                            ivar: ivar,
                            name: ivarName,
                            typeEncoding: ivarEncoding,
                            offset: ivar_getOffset(ivar)
                        )
                    }

                free(ivarsList)
            }
        }

        return ivars
    }
}
