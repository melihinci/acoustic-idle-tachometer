# Acoustic Idle Tachometer

iOS native app feature for estimating engine idle RPM from microphone audio.

## Current Scope

- Swift package core targeting iOS 17+
- Deterministic DSP-oriented RPM models and conversion logic
- Autocorrelation-based synthetic signal analyzer prototype
- SwiftUI MVP screen skeleton
- AVAudioEngine microphone capture service skeleton
- Synthetic signal unit tests for fundamental and second harmonic detection

## Run Tests

```sh
swift test
```

## Open in Xcode

```sh
open AcousticIdleTachometer.xcodeproj
```

The `AcousticIdleTachometer` scheme targets iOS 17+ and is configured for iPhone and iPad.
