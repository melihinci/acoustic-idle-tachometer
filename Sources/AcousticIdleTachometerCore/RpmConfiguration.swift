import Foundation

public enum StrokeType: String, CaseIterable, Codable, Sendable {
    case twoStroke
    case fourStroke
}

public enum MeasurementMode: String, CaseIterable, Codable, Sendable {
    case exhaust
    case engineBay
    case cabin
    case unknown
}

public struct RpmConfiguration: Equatable, Codable, Sendable {
    public var minRpm: Double
    public var maxRpm: Double
    public var cylinderCount: Int
    public var strokeType: StrokeType
    public var measurementMode: MeasurementMode
    public var smoothingAlpha: Double

    public init(
        minRpm: Double = 800,
        maxRpm: Double = 2500,
        cylinderCount: Int = 1,
        strokeType: StrokeType = .fourStroke,
        measurementMode: MeasurementMode = .unknown,
        smoothingAlpha: Double = 0.25
    ) {
        self.minRpm = minRpm
        self.maxRpm = maxRpm
        self.cylinderCount = cylinderCount
        self.strokeType = strokeType
        self.measurementMode = measurementMode
        self.smoothingAlpha = smoothingAlpha
    }
}
