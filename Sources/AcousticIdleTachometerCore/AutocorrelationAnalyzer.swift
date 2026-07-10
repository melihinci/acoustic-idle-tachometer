import Foundation

public struct AutocorrelationEstimate: Equatable, Sendable {
    public var frequencyHz: Double
    public var score: Double
}

public enum AutocorrelationAnalyzer {
    public static func estimateFrequency(
        samples: [Double],
        sampleRate: Double,
        frequencyRange: ClosedRange<Double>
    ) -> AutocorrelationEstimate? {
        guard samples.count > 2, sampleRate > 0, frequencyRange.lowerBound > 0 else {
            return nil
        }

        let minLag = max(1, Int(sampleRate / frequencyRange.upperBound))
        let maxLag = min(samples.count - 1, Int(sampleRate / frequencyRange.lowerBound))
        guard minLag <= maxLag else { return nil }

        let zeroLagEnergy = samples.reduce(0) { $0 + $1 * $1 }
        guard zeroLagEnergy > 0 else { return nil }

        var bestLag = minLag
        var bestCorrelation = -Double.infinity

        for lag in minLag...maxLag {
            var sum = 0.0
            let limit = samples.count - lag
            for index in 0..<limit {
                sum += samples[index] * samples[index + lag]
            }

            let normalized = sum / zeroLagEnergy
            if normalized > bestCorrelation {
                bestCorrelation = normalized
                bestLag = lag
            }
        }

        guard bestCorrelation > 0 else { return nil }
        return AutocorrelationEstimate(
            frequencyHz: sampleRate / Double(bestLag),
            score: min(1, max(0, bestCorrelation))
        )
    }
}
