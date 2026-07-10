import Foundation

public struct PreprocessedAudio: Sendable {
    public var samples: [Double]
    public var rms: Double
    public var clippingRatio: Double
    public var signalTooLow: Bool
    public var signalClipping: Bool
}

public enum AudioPreprocessor {
    public static func preprocess(
        samples: [Double],
        lowSignalRmsThreshold: Double = 0.01,
        clippingThreshold: Double = 0.98,
        clippingRatioThreshold: Double = 0.01
    ) -> PreprocessedAudio {
        guard !samples.isEmpty else {
            return PreprocessedAudio(
                samples: [],
                rms: 0,
                clippingRatio: 0,
                signalTooLow: true,
                signalClipping: false
            )
        }

        let mean = samples.reduce(0, +) / Double(samples.count)
        var centered = samples.map { $0 - mean }
        let rms = sqrt(centered.reduce(0) { $0 + $1 * $1 } / Double(centered.count))
        let clippedCount = samples.filter { abs($0) >= clippingThreshold }.count
        let clippingRatio = Double(clippedCount) / Double(samples.count)

        applyHannWindow(to: &centered)

        return PreprocessedAudio(
            samples: centered,
            rms: rms,
            clippingRatio: clippingRatio,
            signalTooLow: rms < lowSignalRmsThreshold,
            signalClipping: clippingRatio > clippingRatioThreshold
        )
    }

    private static func applyHannWindow(to samples: inout [Double]) {
        guard samples.count > 1 else { return }
        let count = samples.count
        for index in samples.indices {
            let window = 0.5 * (1.0 - cos(2.0 * .pi * Double(index) / Double(count - 1)))
            samples[index] *= window
        }
    }
}
