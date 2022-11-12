import Foundation

extension CharacterSet {

    /// Returns a character set containing characters allowed on files or folders stored on the device, as supported by
    /// the iOS's HFS file system.
    static var filePathAllowed: CharacterSet {

        var excludedCharacters = CharacterSet.newlines
        excludedCharacters.formUnion(CharacterSet.illegalCharacters)
        excludedCharacters.formUnion(CharacterSet.controlCharacters)
        excludedCharacters.insert(charactersIn: ":/")

        return excludedCharacters.inverted
    }
}

extension NSRegularExpression {

    func matches<S: StringProtocol>(in text: S) -> [[String]] {

        let string = (text as? String) ?? String(text)
        let nsString = string as NSString

        let matches = matches(in: string, options: [], range: NSMakeRange(0, nsString.length))

        return matches.map { match in

            (0..<match.numberOfRanges).map { matchRange in

                if match.range(at: matchRange).location != NSNotFound {
                    return nsString.substring(with: match.range(at: matchRange))
                } else {
                    return ""
                }
            }
        }
    }
}
