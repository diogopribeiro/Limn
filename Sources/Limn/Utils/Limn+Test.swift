extension Limn {

    var diffValue: Diff? {

        if case .struct(name: String(reflecting: Diff.self), _) = self {
            return Diff(from: self)
        } else {
            return nil
        }
    }

    var isDiffStruct: Bool {

        if case .struct(name: String(reflecting: Diff.self), _) = self {
            return true
        } else {
            return false
        }
    }

    var isOmitted: Bool {

        if case .omitted = self {
            return true
        } else {
            return false
        }
    }
}
