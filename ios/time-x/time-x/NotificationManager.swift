import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject {
    private let center: UNUserNotificationCenter
    private let timerFinishedIdentifier = "timer-finished-notification"
    private var didRequestAuthorization = false

    override init() {
        center = UNUserNotificationCenter.current()
        super.init()
        center.delegate = self
    }

    func requestAuthorizationIfNeeded() {
        guard !didRequestAuthorization else { return }
        didRequestAuthorization = true

        center.requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error {
                NSLog("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }

    func notifyTimerFinished() {
        clearTimerFinishedNotification()

        let content = UNMutableNotificationContent()
        content.title = "時間になりました"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: timerFinishedIdentifier,
            content: content,
            trigger: nil
        )

        center.add(request) { error in
            if let error {
                NSLog("Failed to schedule timer notification: \(error.localizedDescription)")
            }
        }
    }

    func clearTimerFinishedNotification() {
        center.removePendingNotificationRequests(withIdentifiers: [timerFinishedIdentifier])
        center.removeDeliveredNotifications(withIdentifiers: [timerFinishedIdentifier])
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
