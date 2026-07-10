import Foundation

public struct RpmAnalyzer: Sendable {
    private var smoother = RpmSmoother()
    private var previousStableRpm: Double?

    public init() {}

    public mutating func reset() {
        smoother = RpmSmoother()
        previousStableRpm = nil
    }

    public mutating func analyze(
        samples: [Double],
        sampleRate: Double,
        configuration: RpmConfiguration
    ) -> RpmResult {
        let preprocessed = AudioPreprocessor.preprocess(samples: samples)
        guard !preprocessed.signalTooLow, !preprocessed.samples.isEmpty else {
            return emptyResult(preprocessed: preprocessed)
        }

        let fundamentalRange = RpmMath.expectedFrequencyRange(configuration: configuration)
        var candidates: [RpmCandidate] = []

        for multiplier in [1.0, 2.0, 3.0, 4.0] {
            let searchRange = (fundamentalRange.lowerBound * multiplier)...(fundamentalRange.upperBound * multiplier)
            guard let estimate = AutocorrelationAnalyzer.estimateFrequency(
                samples: preprocessed.samples,
                sampleRate: sampleRate,
                frequencyRange: searchRange
            ) else {
                continue
            }

            candidates.append(contentsOf: makeCandidates(
                detectedFrequencyHz: estimate.frequencyHz,
                autocorrelationScore: estimate.score,
                source: multiplier == 1 ? .autocorrelation : .harmonicCorrected,
                configuration: configuration
            ))
        }

        let ranked = candidates
            .filter { RpmMath.isInConfiguredRange($0.rpm, configuration: configuration) }
            .sorted { $0.totalScore > $1.totalScore }

        guard let selected = ranked.first else {
            return RpmResult(
                rpm: nil,
                smoothedRpm: previousStableRpm,
                detectedFrequencyHz: nil,
                confidence: preprocessed.signalClipping ? 10 : 20,
                signalTooLow: preprocessed.signalTooLow,
                signalClipping: preprocessed.signalClipping,
                rms: preprocessed.rms,
                clippingRatio: preprocessed.clippingRatio,
                candidates: ranked
            )
        }

        let smoothed = smoother.smooth(selected.rpm, alpha: configuration.smoothingAlpha)
        previousStableRpm = smoothed

        return RpmResult(
            rpm: selected.rpm,
            smoothedRpm: smoothed,
            detectedFrequencyHz: selected.frequencyHz,
            confidence: confidence(for: selected, preprocessed: preprocessed),
            signalTooLow: preprocessed.signalTooLow,
            signalClipping: preprocessed.signalClipping,
            rms: preprocessed.rms,
            clippingRatio: preprocessed.clippingRatio,
            candidates: ranked
        )
    }

    private func makeCandidates(
        detectedFrequencyHz: Double,
        autocorrelationScore: Double,
        source: RpmCandidateSource,
        configuration: RpmConfiguration
    ) -> [RpmCandidate] {
        [0.25, 1.0 / 3.0, 0.5, 1.0, 2.0].map { harmonicMultiplier in
            let correctedFrequency = detectedFrequencyHz * harmonicMultiplier
            let rpm = RpmMath.rpm(fromFrequencyHz: correctedFrequency, configuration: configuration)
            let rangeScore = calculateRangeScore(rpm, configuration: configuration)
            let stabilityScore = calculateStabilityScore(candidateRpm: rpm, previousRpm: previousStableRpm)
            let amplitudeScore = 0.5
            let totalScore = amplitudeScore * 0.30
                + autocorrelationScore * 0.30
                + rangeScore * 0.20
                + stabilityScore * 0.20

            return RpmCandidate(
                frequencyHz: correctedFrequency,
                rpm: rpm,
                amplitudeScore: amplitudeScore,
                autocorrelationScore: autocorrelationScore,
                rangeScore: rangeScore,
                stabilityScore: stabilityScore,
                totalScore: totalScore,
                source: source,
                harmonicMultiplier: harmonicMultiplier
            )
        }
    }

    private func calculateRangeScore(_ rpm: Double, configuration: RpmConfiguration) -> Double {
        guard configuration.maxRpm > configuration.minRpm else { return 0 }
        let midpoint = (configuration.minRpm + configuration.maxRpm) / 2
        let halfRange = (configuration.maxRpm - configuration.minRpm) / 2
        return max(0, 1 - abs(rpm - midpoint) / halfRange)
    }

    private func calculateStabilityScore(candidateRpm: Double, previousRpm: Double?) -> Double {
        guard let previousRpm else { return 0.5 }
        let diff = abs(candidateRpm - previousRpm)
        let allowedDiff = previousRpm * 0.15
        guard allowedDiff > 0, diff < allowedDiff else { return 0 }
        return 1 - diff / allowedDiff
    }

    private func confidence(for candidate: RpmCandidate, preprocessed: PreprocessedAudio) -> Int {
        var score = candidate.totalScore
        if preprocessed.signalClipping {
            score *= 0.45
        }
        return Int((min(1, max(0, score)) * 100).rounded())
    }

    private func emptyResult(preprocessed: PreprocessedAudio) -> RpmResult {
        RpmResult(
            rpm: nil,
            smoothedRpm: previousStableRpm,
            detectedFrequencyHz: nil,
            confidence: 0,
            signalTooLow: preprocessed.signalTooLow,
            signalClipping: preprocessed.signalClipping,
            rms: preprocessed.rms,
            clippingRatio: preprocessed.clippingRatio,
            candidates: []
        )
    }
}
