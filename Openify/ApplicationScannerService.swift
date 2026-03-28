import AppKit
import Foundation

struct ApplicationScannerService {
    private let scanDirectories: [URL] = [
        URL(fileURLWithPath: "/Applications", isDirectory: true),
        URL(fileURLWithPath: "/System/Applications", isDirectory: true),
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(
            "Applications", isDirectory: true),
    ]

    nonisolated func scanApplications() -> [InstalledApp] {
        let fileManager = FileManager.default
        var seenBundleIDs = Set<String>()
        var seenPaths = Set<String>()
        var apps: [InstalledApp] = []

        for directory in scanDirectories {
            guard
                let urls = try? fileManager.contentsOfDirectory(
                    at: directory,
                    includingPropertiesForKeys: [.isDirectoryKey, .isApplicationKey],
                    options: [.skipsHiddenFiles]
                )
            else {
                continue
            }

            for appURL in urls where appURL.pathExtension.lowercased() == "app" {
                guard seenPaths.insert(appURL.path).inserted else { continue }
                guard let bundle = Bundle(url: appURL) else { continue }

                let displayName =
                    (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let fallbackName = (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let appName =
                    (displayName?.isEmpty == false ? displayName : fallbackName)
                    ?? appURL.deletingPathExtension().lastPathComponent
                let bundleID = bundle.bundleIdentifier

                if let bundleID, !bundleID.isEmpty {
                    guard seenBundleIDs.insert(bundleID).inserted else { continue }
                }

                let icon = NSWorkspace.shared.icon(forFile: appURL.path)
                icon.size = NSSize(width: 28, height: 28)

                apps.append(
                    InstalledApp(
                        id: bundleID ?? appURL.path,
                        name: appName,
                        bundleIdentifier: bundleID,
                        url: appURL,
                        icon: icon
                    )
                )
            }
        }

        return apps.sorted { lhs, rhs in
            lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }
}
