import AppKit
import CoreServices
import Foundation
import Security
import UniformTypeIdentifiers

struct DefaultAssociationService {
    func queryCurrentHandler(for ext: String) -> ExtensionAssociationInfo {
        guard let type = resolveType(for: ext) else {
            return ExtensionAssociationInfo(
                ext: ext, utiIdentifier: nil, handlerBundleID: nil, handlerAppName: nil)
        }

        let handlerBundleID =
            LSCopyDefaultRoleHandlerForContentType(type.identifier as CFString, LSRolesMask.all)?
            .takeRetainedValue() as String?
        let appName = handlerBundleID.flatMap(resolveAppName(bundleID:))

        return ExtensionAssociationInfo(
            ext: ext,
            utiIdentifier: type.identifier,
            handlerBundleID: handlerBundleID,
            handlerAppName: appName
        )
    }

    func setDefaultHandler(for ext: String, bundleID: String) -> ExtensionApplyResult {
        guard let type = resolveType(for: ext) else {
            return ExtensionApplyResult(ext: ext, success: false, message: "无法识别该扩展名对应的 UTType")
        }

        let status = LSSetDefaultRoleHandlerForContentType(
            type.identifier as CFString,
            LSRolesMask.all,
            bundleID as CFString
        )

        guard status == noErr else {
            return ExtensionApplyResult(
                ext: ext,
                success: false,
                message: osStatusDescription(status)
            )
        }

        return ExtensionApplyResult(ext: ext, success: true, message: "设置成功")
    }

    private func resolveType(for ext: String) -> UTType? {
        if let type = UTType(filenameExtension: ext) {
            return type
        }
        return UTType(tag: ext, tagClass: .filenameExtension, conformingTo: nil)
    }

    private func resolveAppName(bundleID: String) -> String? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID),
            let bundle = Bundle(url: url)
        else {
            return nil
        }
        let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let bundleName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
        return (displayName?.isEmpty == false ? displayName : bundleName)
            ?? url.deletingPathExtension().lastPathComponent
    }

    private func osStatusDescription(_ status: OSStatus) -> String {
        if let secMessage = SecCopyErrorMessageString(status, nil) as String? {
            return secMessage
        }
        return "Launch Services 返回错误：OSStatus \(status)"
    }
}
