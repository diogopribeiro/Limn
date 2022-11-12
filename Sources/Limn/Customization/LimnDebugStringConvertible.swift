/// A `CustomDebugStringConvertible` implementation that returns a debug description obtained via `Limn.stringDump()`.
protocol LimnDebugStringConvertible: CustomDebugStringConvertible { }

extension LimnDebugStringConvertible {

    var debugDescription: String {
        Limn(of: self).stringDump()
    }
}
