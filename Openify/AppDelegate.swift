import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")
        clearSavedStateIfNeeded()
    }

    func applicationShouldSaveApplicationState(_ app: NSApplication) -> Bool {
        false
    }

    func applicationShouldRestoreApplicationState(_ app: NSApplication) -> Bool {
        false
    }

    private func clearSavedStateIfNeeded() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        let statePath = ("~/Library/Saved Application State/\(bundleID).savedState" as NSString)
            .expandingTildeInPath
        try? FileManager.default.removeItem(atPath: statePath)
    }
}
