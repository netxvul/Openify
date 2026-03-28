import AppKit

struct InstalledApp: Identifiable {
    let id: String
    let name: String
    let bundleIdentifier: String?
    let url: URL
    let icon: NSImage
}
