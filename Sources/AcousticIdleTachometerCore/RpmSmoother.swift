import Foundation

public struct RpmSmoother: Sendable {
    public private(set) var previousSmoothedRpm: Double?

    public init(previousSmoothedRpm: Double? = nil) {
        self.previousSmoothedRpm = previousSmoothedRpm
    }

    public mutating func smooth(_ rpm: Double, alpha: Double) -> Double {
        let clampedAlpha = min(1, max(0, alpha))
        guard let previousSmoothedRpm else {
            self.previousSmoothedRpm = rpm
            return rpm
        }

        let smoothed = clampedAlpha * rpm + (1 - clampedAlpha) * previousSmoothedRpm
        self.previousSmoothedRpm = smoothed
        return smoothed
    }
}
