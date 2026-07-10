import XCTest
@testable import AcousticIdleTachometerCore

final class RpmAnalyzerSyntheticSignalTests: XCTestCase {
    func testAnalyzerDetectsFourStrokeSingleCylinderSyntheticIdleSignal() {
        let sampleRate = 44_100.0
        let configuration = RpmConfiguration(
            minRpm: 800,
            maxRpm: 2500,
            cylinderCount: 1,
            strokeType: .fourStroke
        )
        let targetRpm = 1_200.0
        let fundamentalHz = RpmMath.frequencyHz(fromRpm: targetRpm, configuration: configuration)
        let samples = SyntheticSignalGenerator.sineWave(
            frequencyHz: fundamentalHz,
            sampleRate: sampleRate,
            durationSeconds: 0.5
        )

        var analyzer = RpmAnalyzer()
        let result = analyzer.analyze(samples: samples, sampleRate: sampleRate, configuration: configuration)

        XCTAssertNotNil(result.smoothedRpm)
        XCTAssertEqual(result.smoothedRpm ?? 0, targetRpm, accuracy: 20)
        XCTAssertFalse(result.signalTooLow)
        XCTAssertFalse(result.signalClipping)
        XCTAssertGreaterThan(result.confidence, 40)
    }

    func testAnalyzerCorrectsSecondHarmonicSyntheticSignal() {
        let sampleRate = 44_100.0
        let configuration = RpmConfiguration(
            minRpm: 800,
            maxRpm: 2500,
            cylinderCount: 1,
            strokeType: .fourStroke
        )
        let targetRpm = 1_200.0
        let fundamentalHz = RpmMath.frequencyHz(fromRpm: targetRpm, configuration: configuration)
        let samples = SyntheticSignalGenerator.sineWave(
            frequencyHz: fundamentalHz,
            sampleRate: sampleRate,
            durationSeconds: 0.5,
            harmonicMultiplier: 2
        )

        var analyzer = RpmAnalyzer()
        let result = analyzer.analyze(samples: samples, sampleRate: sampleRate, configuration: configuration)

        XCTAssertNotNil(result.smoothedRpm)
        XCTAssertEqual(result.smoothedRpm ?? 0, targetRpm, accuracy: 25)
        XCTAssertTrue(result.candidates.contains { abs($0.rpm - targetRpm) < 25 })
    }
}
