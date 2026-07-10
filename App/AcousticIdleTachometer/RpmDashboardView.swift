import SwiftUI
#if canImport(AcousticIdleTachometerCore)
import AcousticIdleTachometerCore
#endif

struct RpmDashboardView: View {
    @StateObject private var viewModel = RpmDashboardViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("RPM Range") {
                    TextField("Min RPM", value: $viewModel.minRpm, format: .number)
                        .keyboardType(.numberPad)
                    TextField("Max RPM", value: $viewModel.maxRpm, format: .number)
                        .keyboardType(.numberPad)
                }

                Section("Engine Configuration") {
                    Picker("Cylinder Count", selection: $viewModel.cylinderCount) {
                        ForEach([1, 2, 3, 4, 5, 6, 8, 10, 12], id: \.self) { count in
                            Text("\(count)").tag(count)
                        }
                    }

                    Picker("Engine Type", selection: $viewModel.strokeType) {
                        Text("2-stroke").tag(StrokeType.twoStroke)
                        Text("4-stroke").tag(StrokeType.fourStroke)
                    }
                    .pickerStyle(.segmented)

                    Picker("Measurement Mode", selection: $viewModel.measurementMode) {
                        Text("Exhaust").tag(MeasurementMode.exhaust)
                        Text("Engine bay").tag(MeasurementMode.engineBay)
                        Text("Cabin").tag(MeasurementMode.cabin)
                        Text("Unknown").tag(MeasurementMode.unknown)
                    }
                }

                Section {
                    Button(viewModel.isListening ? "Stop Listening" : "Start Listening") {
                        viewModel.toggleListening()
                    }
                }

                Section("Current Reading") {
                    LabeledContent("RPM", value: viewModel.rpmText)
                    LabeledContent("Confidence", value: viewModel.confidenceText)
                    LabeledContent("Detected Frequency", value: viewModel.frequencyText)
                    LabeledContent("Signal Status", value: viewModel.signalStatusText)
                }

                if viewModel.showDebug {
                    Section("Debug") {
                        LabeledContent("RMS", value: viewModel.rmsText)
                        LabeledContent("Clipping", value: viewModel.clippingText)
                        ForEach(Array(viewModel.candidateRows.enumerated()), id: \.offset) { _, row in
                            Text(row)
                                .font(.caption.monospaced())
                        }
                    }
                }

                Section {
                    Toggle("Debug Panel", isOn: $viewModel.showDebug)
                }
            }
            .navigationTitle("Idle Tachometer")
        }
    }
}
