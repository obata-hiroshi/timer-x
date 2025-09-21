import Foundation
import Combine

@MainActor
public final class CountdownTimer: ObservableObject {
    public enum State: Equatable {
        case idle
        case running
        case paused
        case finished
    }

    @Published public private(set) var state: State = .idle
    @Published public private(set) var remainingSeconds: Int = 0
    @Published public private(set) var selectedPresetSeconds: Int?

    public var formattedTime: String {
        CountdownTimer.format(remainingSeconds)
    }

    public var startStopButtonTitle: String {
        state == .running ? "ストップ" : "スタート"
    }

    public var onDidFinish: (() -> Void)?

    private var timer: Timer?
    private var targetDate: Date?

    public init() {}

    public func applyPreset(seconds: Int) {
        stopTimer()
        remainingSeconds = max(0, seconds)
        state = .idle
        targetDate = nil
        selectedPresetSeconds = seconds
    }

    public func toggleStartStop() {
        switch state {
        case .running:
            pause()
        case .paused:
            startIfNeeded()
        case .idle:
            startIfNeeded()
        case .finished:
            break
        }
    }

    public func reset() {
        stopTimer()
        remainingSeconds = 0
        state = .idle
        targetDate = nil
        selectedPresetSeconds = nil
    }

    private func startIfNeeded() {
        guard remainingSeconds > 0 else { return }
        startTimer()
    }

    private func pause() {
        stopTimer()
        state = .paused
        targetDate = nil
    }

    private func startTimer() {
        stopTimer()
        state = .running
        targetDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        scheduleTimer()
        // Render immediately in case start is requested while paused mid-second
        handleTick()
    }

    private func scheduleTimer() {
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.handleTick()
            }
        }
        timer.tolerance = 0.05
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func handleTick() {
        guard state == .running else { return }
        guard let targetDate else { return }

        let secondsLeft = max(0, Int(ceil(targetDate.timeIntervalSinceNow)))
        if secondsLeft != remainingSeconds {
            remainingSeconds = secondsLeft
        }

        if secondsLeft == 0 {
            finish()
        }
    }

    private func finish() {
        stopTimer()
        targetDate = nil
        state = .finished
        remainingSeconds = 0
        onDidFinish?()
    }

    public static func format(_ seconds: Int) -> String {
        let clamped = max(0, seconds)
        let minutes = clamped / 60
        let remaining = clamped % 60
        return String(format: "%02d:%02d", minutes, remaining)
    }
}
