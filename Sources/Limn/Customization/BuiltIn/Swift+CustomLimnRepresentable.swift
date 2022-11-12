extension ClosedRange: CustomLimnRepresentable {

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {
        .value(description: "\(lowerBound)...\(upperBound)")
    }
}

extension PartialRangeFrom: CustomLimnRepresentable {

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {
        .value(description: "\(lowerBound)...")
    }
}

extension PartialRangeThrough: CustomLimnRepresentable {

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {
        .value(description: "...\(upperBound)")
    }
}

extension PartialRangeUpTo: CustomLimnRepresentable {

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {
        .value(description: "..<\(upperBound)")
    }
}

extension Range: CustomLimnRepresentable {

    public func customLimn(defaultLimn: () -> Limn, context: Limn.InitContext) -> Limn {
        .value(description: "\(lowerBound)..<\(upperBound)")
    }
}
