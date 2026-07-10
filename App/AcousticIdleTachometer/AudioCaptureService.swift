import AVFoundation
import Foundation

final class AudioCaptureService {
    private let engine = AVAudioEngine()
    private var rollingSamples: [Double] = []
    private let windowSizeSeconds = 0.5
    private let hopSizeSeconds = 0.1

    func start(onFrame: @escaping (_ samples: [Double], _ sampleRate: Double) -> Void) throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [.allowBluetooth])
        try session.setActive(true)

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate
        let hopSize = AVAudioFrameCount(sampleRate * hopSizeSeconds)
        let maxWindowSamples = Int(sampleRate * windowSizeSeconds)

        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: hopSize, format: format) { [weak self] buffer, _ in
            guard let self, let channelData = buffer.floatChannelData else { return }
            let frameLength = Int(buffer.frameLength)
            let channel = channelData[0]
            let samples = (0..<frameLength).map { Double(channel[$0]) }

            self.rollingSamples.append(contentsOf: samples)
            if self.rollingSamples.count > maxWindowSamples {
                self.rollingSamples.removeFirst(self.rollingSamples.count - maxWindowSamples)
            }

            guard self.rollingSamples.count == maxWindowSamples else { return }
            onFrame(self.rollingSamples, sampleRate)
        }

        engine.prepare()
        try engine.start()
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        rollingSamples.removeAll(keepingCapacity: true)
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
