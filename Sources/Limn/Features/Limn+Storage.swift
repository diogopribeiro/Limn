import Foundation

extension Limn {

    // MARK: - Types

    private enum StorageConfiguration {

        static let baseFolder: FileManager.SearchPathDirectory = .documentDirectory
        static let fileExtension = "limn"
        static let subfolderName = ".limn"
    }

    // MARK: - Public API

    /// Clears all `Limn`s currently saved on the app's container.
    ///
    /// - Returns: The total amount of entries removed.
    @discardableResult public static func clearAll() -> Int {

        let basePath = self.basePath
        guard let basePath = basePath, FileManager.default.fileExists(atPath: basePath.path) else {
            return 0
        }

        do {
            let fileURLs = try FileManager.default
                .contentsOfDirectory(at: basePath, includingPropertiesForKeys: nil)
                .filter { $0.absoluteString.hasSuffix(StorageConfiguration.fileExtension) }
            try fileURLs.forEach { existingFileURL in
                try FileManager.default.removeItem(at: existingFileURL)
            }
            return fileURLs.count
        } catch {
            return 0
        }
    }

    /// Clears a `Limn` that was previously saved on the app's container.
    ///
    /// - Parameter id: The unique identifier for the saved `Limn`.
    /// - Returns: `true` if a `Limn` for the specified identifier was found and cleared fromn the app's container.
    @discardableResult public static func clear(_ id: Int64) -> Bool {
        clear("\(id)")
    }

    /// Clears a `Limn` that was previously saved on the app's container.
    ///
    /// - Parameter id: The unique identifier for the saved `Limn`.
    /// - Returns: `true` if a `Limn` for the specified identifier was found and cleared fromn the app's container.
    @discardableResult public static func clear<S: StringProtocol>(_ id: S) -> Bool {

        let filePath = filePath(forLimnWithId: id)?.path
        guard let filePath = filePath, FileManager.default.fileExists(atPath: filePath) else {
            return false
        }

        do {
            try FileManager.default.removeItem(atPath: filePath)
            return true
        } catch {
            return false
        }
    }

    /// Retrieves a list of identifiers for all `Limn`s currently saved on the app's container.
    ///
    /// - Returns: A list containing the identifier of each `Limn` currently saved on the app's container, or `nil` if
    /// an error has occurred.
    public static func list() -> [String]? {

        guard let basePath = basePath else {
            return nil
        }

        do {
            let fileURLs = try FileManager.default
                .contentsOfDirectory(at: basePath, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == StorageConfiguration.fileExtension }
            let fileNames = fileURLs
                .map { $0.deletingPathExtension().lastPathComponent }
                .filter { !$0.isEmpty }
            return fileNames
        } catch {
            return nil
        }
    }

    /// Retrieves a `Limn` that was previously saved on the app's container.
    ///
    /// - Parameter id: The unique identifier for the saved `Limn`.
    /// - Returns: The previoulsy saved `Limn` instance for the specified ìdentifier, or `nil` if none was found or an
    ///   error has occurred.
    public static func load(_ id: UInt64) -> Limn? {
        load("\(id)")
    }

    /// Retrieves a `Limn` that was previously saved on the app's container.
    ///
    /// - Parameter id: The unique identifier for the saved `Limn`.
    /// - Returns: The previoulsy saved `Limn` instance for the specified ìdentifier, or `nil` if none was found or an
    ///   error has occurred.
    public static func load<S: StringProtocol>(_ id: S) -> Limn? {

        let filePath = Self.filePath(forLimnWithId: id)?.path
        guard let filePath = filePath, FileManager.default.fileExists(atPath: filePath) else {
            return nil
        }

        do {
            let encodedLimnData = FileManager.default.contents(atPath: filePath)
            let decodedLimn = try encodedLimnData.map { try JSONDecoder().decode(Limn.self, from: $0) }
            return decodedLimn
        } catch {
            return nil
        }
    }

    /// Persists a `Limn` on the app's container for later retrieval.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for this `Limn`.
    ///   - overwrite: Whether any existing value for the specified identifier should be overwritten.
    /// - Returns: `true` if the property was saved or updated successfully, `false` otherwise.
    @discardableResult public func save(as id: UInt64, overwrite: Bool = true) -> Bool {
        save(as: "\(id)", overwrite: overwrite)
    }

    /// Persists a `Limn` on the app's container for later retrieval.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for this `Limn`.
    ///   - overwrite: Whether any existing value for the specified identifier should be overwritten.
    /// - Returns: `true` if the property was saved or updated successfully, `false` otherwise.
    @discardableResult public func save<S: StringProtocol>(as id: S, overwrite: Bool = true) -> Bool {

        let fileUrl = Self.filePath(forLimnWithId: id)
        guard let fileUrl = fileUrl, overwrite || !FileManager.default.fileExists(atPath: fileUrl.path) else {
            return false
        }

        do {
            let encodedLimn = try JSONEncoder().encode(self)
            let folderUrl = fileUrl.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true)
            let result = FileManager.default.createFile(atPath: fileUrl.path, contents: encodedLimn, attributes: nil)
            return result
        } catch {
            return false
        }
    }

    // MARK: - Private properties and methods

    private static var basePath: URL? = {
        FileManager.default.urls(for: StorageConfiguration.baseFolder, in: .userDomainMask).first?
            .appendingPathComponent(StorageConfiguration.subfolderName, isDirectory: true)
    }()

    private static func filePath<S: StringProtocol>(forLimnWithId id: S) -> URL? {
        guard id.unicodeScalars.allSatisfy(CharacterSet.filePathAllowed.contains) else { return nil }
        return basePath?.appendingPathComponent("\(id).\(StorageConfiguration.fileExtension)", isDirectory: false)
    }
}
