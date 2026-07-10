import Foundation

public enum RpmMath {
    public static func rpm(fromFrequencyHz frequencyHz: Double, configuration: RpmConfiguration) -> Double {
        switch configuration.strokeType {
        case .fourStroke:
            return frequencyHz * 120.0 / Double(configuration.cylinderCount)
        case .twoStroke:
            return frequencyHz * 60.0 / Double(configuration.cylinderCount)
        }
    }

    public static func frequencyHz(fromRpm rpm: Double, configuration: RpmConfiguration) -> Double {
        switch configuration.strokeType {
        case .fourStroke:
            return rpm / 120.0 * Double(configuration.cylinderCount)
        case .twoStroke:
            return rpm / 60.0 * Double(configuration.cylinderCount)
        }
    }

    public static func expectedFrequencyRange(configuration: RpmConfiguration) -> ClosedRange<Double> {
        let lower = frequencyHz(fromRpm: configuration.minRpm, configuration: configuration)
        let upper = frequencyHz(fromRpm: configuration.maxRpm, configuration: configuration)
        return min(lower, upper)...max(lower, upper)
    }

    public static func isInConfiguredRange(_ rpm: Double, configuration: RpmConfiguration) -> Bool {
        rpm >= configuration.minRpm && rpm <= configuration.maxRpm
    }
}
