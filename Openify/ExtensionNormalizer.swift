import Foundation

enum ExtensionNormalizer {
    static func normalize(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let withoutDot: String
        if trimmed.hasPrefix(".") {
            withoutDot = String(trimmed.dropFirst())
        } else {
            withoutDot = trimmed
        }

        let normalized = withoutDot.lowercased()
        let isValid =
            normalized.range(
                of: #"^[a-z0-9][a-z0-9+\-_]*$"#,
                options: .regularExpression
            ) != nil

        return isValid ? normalized : nil
    }

    static func display(_ ext: String) -> String {
        ".\(ext)"
    }
}
