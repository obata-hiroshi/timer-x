import Testing
@testable import time_x

@MainActor
struct CountdownTimerTests {

    @Test func formattingOutput() {
        #expect(CountdownTimer.format(0) == "00.00")
        #expect(CountdownTimer.format(5) == "00.05")
        #expect(CountdownTimer.format(59) == "00.59")
        #expect(CountdownTimer.format(60) == "01.00")
        #expect(CountdownTimer.format(185) == "03.05")
        #expect(CountdownTimer.format(600) == "10.00")
        #expect(CountdownTimer.format(900) == "15.00")
    }

    @Test func presetResetsStateAndSeconds() async throws {
        let timer = CountdownTimer()
        timer.applyPreset(seconds: 180)
        #expect(timer.state == .idle)
        #expect(timer.remainingSeconds == 180)

        timer.toggleStartStop()
        #expect(timer.state == .running)

        timer.applyPreset(seconds: 300)
        #expect(timer.state == .idle)
        #expect(timer.remainingSeconds == 300)

        timer.applyPreset(seconds: 600)
        #expect(timer.state == .idle)
        #expect(timer.remainingSeconds == 600)

        timer.applyPreset(seconds: 900)
        #expect(timer.state == .idle)
        #expect(timer.remainingSeconds == 900)

        timer.reset()
    }

    @Test func startStopTogglesBetweenRunningAndPaused() async throws {
        let timer = CountdownTimer()
        timer.applyPreset(seconds: 180)

        timer.toggleStartStop()
        #expect(timer.state == .running)

        timer.toggleStartStop()
        #expect(timer.state == .paused)

        timer.toggleStartStop()
        #expect(timer.state == .running)

        timer.reset()
    }

    @Test func startIgnoredWhenNoRemainingTime() async throws {
        let timer = CountdownTimer()
        timer.toggleStartStop()
        #expect(timer.state == .idle)
    }

    @Test func countdownFinishesAndInvokesCallback() async throws {
        let timer = CountdownTimer()
        var didFinish = false
        timer.onDidFinish = { didFinish = true }

        timer.applyPreset(seconds: 1)
        timer.toggleStartStop()

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1.3))

        #expect(timer.state == .finished)
        #expect(timer.remainingSeconds == 0)
        #expect(didFinish)

        timer.reset()
    }
}
