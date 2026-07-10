import XCTest
@testable import AcousticIdleTachometerCore

final class RpmMathTests: XCTestCase {
    func testFourStrokeSingleCylinderConversion() {
        let configuration = RpmConfiguration(cylinderCount: 1, strokeType: .fourStroke)

        XCTAssertEqual(
            RpmMath.rpm(fromFrequencyHz: 10, configuration: configuration),
            1200,
            accuracy: 0.001
        )
    }

    func testTwoStrokeSingleCylinderConversion() {
        let configuration = RpmConfiguration(cylinderCount: 1, strokeType: .twoStroke)

        XCTAssertEqual(
            RpmMath.rpm(fromFrequencyHz: 20, configuration: configuration),
            1200,
            accuracy: 0.001
        )
    }

    func testExpectedFrequencyRangeForFourStrokeIdle() {
        let configuration = RpmConfiguration(
            minRpm: 800,
            maxRpm: 2500,
            cylinderCount: 1,
            strokeType: .fourStroke
        )

        let range = RpmMath.expectedFrequencyRange(configuration: configuration)

        XCTAssertEqual(range.lowerBound, 6.666, accuracy: 0.01)
        XCTAssertEqual(range.upperBound, 20.833, accuracy: 0.01)
    }
}
