import Foundation

/// A `TextOutputStream` that outputs data to a `FileHandle`.
public struct FileHandleTextOutputStream: TextOutputStream {

    let fileHandle: FileHandle

    public init(fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }

    public mutating func write(_ string: String) {

        let stringData = Data(string.utf8)
        if #available(iOS 13.4, macOS 10.15.4, watchOS 6.2, tvOS 13.4, *) {
            try? fileHandle.write(contentsOf: stringData)
        } else {
            fileHandle.write(stringData)
        }
    }
}
