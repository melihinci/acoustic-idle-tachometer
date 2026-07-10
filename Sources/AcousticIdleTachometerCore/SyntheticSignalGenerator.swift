import Foundation

public enum SyntheticSignalGenerator {
    public static func sineWave(
        frequencyHz: Double,
        sampleRate: Double,
        durationSeconds: Double,
        amplitude: Double = 0.8,
        harmonicMultiplier: Double = 1
    ) -> [Double] {
        let count = Int(sampleRate * durationSeconds)
        let actualFrequency = frequencyHz * harmonicMultiplier
        return (0..<count).map { index in
            amplitude * sin(2 * .pi * actualFrequency * Double(index) / sampleRate)
        }
    }
}
