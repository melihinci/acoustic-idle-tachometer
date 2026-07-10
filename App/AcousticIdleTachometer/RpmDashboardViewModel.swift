import Foundation
import AcousticIdleTachometerCore

@MainActor
final class RpmDashboardViewModel: ObservableObject {
    @Published var minRpm = 800.0
    @Published var maxRpm = 2500.0
    @Published var cylinderCount = 1
    @Published var strokeType: StrokeType = .fourStroke
    @Published var measurementMode: MeasurementMode = .unknown
    @Published var showDebug = false
    @Published private(set) var isListening = false
    @Published private(set) var result = RpmResult(
        rpm: nil,
        smoothedRpm: nil,
        detectedFrequencyHz: nil,
        confidence: 0,
        signalTooLow: true,
        signalClipping: false,
        rms: 0,
        clippingRatio: 0,
        candidates: []
    )

    private var analyzer = RpmAnalyzer()
    private let audioCapture = AudioCaptureService()

    var configuration: RpmConfiguration {
        RpmConfiguration(
            minRpm: minRpm,
            maxRpm: maxRpm,
            cylinderCount: cylinderCount,
            strokeType: strokeType,
            measurementMode: measurementMode
        )
    }

    var rpmText: String {
        guard let rpm = result.smoothedRpm else { return "--" }
        return "\(Int(rpm.rounded())) RPM"
    }

    var confidenceText: String {
        "\(result.confidence)%"
    }

    var frequencyText: String {
        guard let frequency = result.detectedFrequencyHz else { return "--" }
        return String(format: "%.2f Hz", frequency)
    }

    var signalStatusText: String {
        if result.signalTooLow {
            return "Signal too low"
        }
        if result.signalClipping {
            return "Signal too loud"
        }
        return "Good"
    }

    var rmsText: String {
        String(format: "%.4f", result.rms)
    }

    var clippingText: String {
        String(format: "%.2f%%", result.clippingRatio * 100)
    }

    var candidateRows: [String] {
        result.candidates.prefix(8).map {
            String(format: "%.2f Hz -> %.0f RPM score %.2f", $0.frequencyHz, $0.rpm, $0.totalScore)
        }
    }

    func toggleListening() {
        if isListening {
            audioCapture.stop()
            isListening = false
            return
        }

        do {
            try audioCapture.start { [weak self] samples, sampleRate in
                Task { @MainActor in
                    self?.analyzePreviewSamples(samples, sampleRate: sampleRate)
                }
            }
            isListening = true
        } catch {
            isListening = false
        }
    }

    func analyzePreviewSamples(_ samples: [Double], sampleRate: Double) {
        result = analyzer.analyze(samples: samples, sampleRate: sampleRate, configuration: configuration)
    }
}
