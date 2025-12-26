import XCTest

class RoundTimerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
    }

    func testTimerStartAndElements() throws {
        let app = XCUIApplication()
        
        // Assert we are on Settings screen initially
        XCTAssertTrue(app.navigationBars["Round Timer"].exists)
        
        // Find Start Button and tap it
        let startButton = app.buttons["Start Workout"]
        XCTAssertTrue(startButton.exists)
        startButton.tap()
        
        // Verify we navigated to Timer View
        // Should show "GET READY" initially
        let statusText = app.staticTexts["GET READY"]
        XCTAssertTrue(statusText.waitForExistence(timeout: 2))
        
        // Verify Stop Button exists using identifier
        let stopButton = app.buttons["StopButton"]
        XCTAssertTrue(stopButton.exists)
        
        // Verify Timer Text exists using identifier
        let timerText = app.staticTexts["TimerText"]
        XCTAssertTrue(timerText.exists)
    }
}
