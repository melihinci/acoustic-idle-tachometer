import Foundation

public enum RpmCandidateSource: String, Codable, Sendable {
    case autocorrelation
    case harmonicCorrected
}

public struct RpmCandidate: Equatable, Codable, Sendable {
    public var frequencyHz: Double
    public var rpm: Double
    public var amplitudeScore: Double
    public var autocorrelationScore: Double
    public var rangeScore: Double
    public var stabilityScore: Double
    public var totalScore: Double
    public var source: RpmCandidateSource
    public var harmonicMultiplier: Double

    public init(
        frequencyHz: Double,
        rpm: Double,
        amplitudeScore: Double,
        autocorrelationScore: Double,
        rangeScore: Double,
        stabilityScore: Double,
        totalScore: Double,
        source: RpmCandidateSource,
        harmonicMultiplier: Double
    ) {
        self.frequencyHz = frequencyHz
        self.rpm = rpm
        self.amplitudeScore = amplitudeScore
        self.autocorrelationScore = autocorrelationScore
        self.rangeScore = rangeScore
        self.stabilityScore = stabilityScore
        self.totalScore = totalScore
        self.source = source
        self.harmonicMultiplier = harmonicMultiplier
    }
}

public struct RpmResult: Equatable, Sendable {
    public var rpm: Double?
    public var smoothedRpm: Double?
    public var detectedFrequencyHz: Double?
    public var confidence: Int
    public var signalTooLow: Bool
    public var signalClipping: Bool
    public var rms: Double
    public var clippingRatio: Double
    public var candidates: [RpmCandidate]

    public init(
        rpm: Double?,
        smoothedRpm: Double?,
        detectedFrequencyHz: Double?,
        confidence: Int,
        signalTooLow: Bool,
        signalClipping: Bool,
        rms: Double,
        clippingRatio: Double,
        candidates: [RpmCandidate]
    ) {
        self.rpm = rpm
        self.smoothedRpm = smoothedRpm
        self.detectedFrequencyHz = detectedFrequencyHz
        self.confidence = confidence
        self.signalTooLow = signalTooLow
        self.signalClipping = signalClipping
        self.rms = rms
        self.clippingRatio = clippingRatio
        self.candidates = candidates
    }
}
