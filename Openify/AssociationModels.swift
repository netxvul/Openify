import Foundation

struct ExtensionAssociationInfo {
    let ext: String
    let utiIdentifier: String?
    let handlerBundleID: String?
    let handlerAppName: String?
}

struct ExtensionApplyResult {
    let ext: String
    let success: Bool
    let message: String
}

struct AlertInfo: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
