import XCTest
@testable import RoundTimer // Replace with your actual module name if different

@MainActor
class TimerModelTests: XCTestCase {
    
    var timerModel: RoundTimerModel!
    
    override func setUp() {
        super.setUp()
        timerModel = RoundTimerModel()
    }
    
    override func tearDown() {
        timerModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(timerModel.phase, .idle)
        XCTAssertEqual(timerModel.currentRound, 1)
        XCTAssertFalse(timerModel.isPaused)
    }
    
    func testStartTriggersPrepare() {
        timerModel.start()
        XCTAssertEqual(timerModel.phase, .prepare)
        // Default prepare time is 10s
        XCTAssertEqual(timerModel.timeRemaining, 10)
    }
    
    func testPauseAndResume() {
        timerModel.start() // Goes to prepare
        timerModel.pause()
        XCTAssertTrue(timerModel.isPaused)
        
        timerModel.resume()
        XCTAssertFalse(timerModel.isPaused)
        XCTAssertEqual(timerModel.phase, .prepare)
    }
    
    func testStopResetsState() {
        timerModel.start()
        timerModel.stop()
        
        XCTAssertEqual(timerModel.phase, .idle)
        XCTAssertEqual(timerModel.currentRound, 1)
        XCTAssertFalse(timerModel.isPaused)
    }
}
