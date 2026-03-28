import Combine
import Foundation
import UniformTypeIdentifiers

@MainActor
final class MainViewModel: ObservableObject {
    struct ToolbarGroup: Identifiable {
        let id: String
        let title: String
    }

    @Published var apps: [InstalledApp] = []
    @Published var searchText = ""
    @Published var selectedAppID: String?
    @Published var selectedExtensions: Set<String> = []
    @Published var customExtensionInput = ""
    @Published var toolbarGroupID = "all"
    @Published var associationMap: [String: ExtensionAssociationInfo] = [:]
    @Published var isLoadingApps = false
    @Published var isApplying = false
    @Published var isDropTargeted = false
    @Published var alertInfo: AlertInfo?

    let categories = ExtensionDataSource.categories

    private let scanner = ApplicationScannerService()
    private let associationService = DefaultAssociationService()
    private var bootstrapped = false

    var filteredApps: [InstalledApp] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(keyword) }
    }

    var selectedApp: InstalledApp? {
        guard let selectedAppID else { return nil }
        return apps.first { $0.id == selectedAppID }
    }

    var canApply: Bool {
        selectedApp?.bundleIdentifier != nil && !selectedExtensions.isEmpty && !isApplying
    }

    var toolbarGroups: [ToolbarGroup] {
        [ToolbarGroup(id: "all", title: "全部分组")]
            + categories.map { ToolbarGroup(id: $0.id, title: $0.title) }
    }

    var selectedExtensionsSorted: [String] {
        selectedExtensions.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    func bootstrap() async {
        guard !bootstrapped else { return }
        bootstrapped = true
        await reloadApps()
        await refreshKnownExtensions()
    }

    func reloadApps() async {
        isLoadingApps = true
        let loaded = scanner.scanApplications()
        apps = loaded
        if let selectedAppID, !apps.contains(where: { $0.id == selectedAppID }) {
            self.selectedAppID = nil
        }
        isLoadingApps = false
    }

    func toggleExtension(_ ext: String) {
        if selectedExtensions.contains(ext) {
            selectedExtensions.remove(ext)
        } else {
            selectedExtensions.insert(ext)
        }
    }

    func selectAll(in category: ExtensionCategory) {
        selectedExtensions.formUnion(category.extensions)
    }

    func clearCategory(in category: ExtensionCategory) {
        selectedExtensions.subtract(category.extensions)
    }

    func clearSelection() {
        selectedExtensions.removeAll()
    }

    func selectAllInToolbarGroup() {
        let targets = extensionsForToolbarGroup()
        selectedExtensions.formUnion(targets)
    }

    func clearToolbarGroupSelection() {
        let targets = extensionsForToolbarGroup()
        selectedExtensions.subtract(targets)
    }

    func removeSelectedExtension(_ ext: String) {
        selectedExtensions.remove(ext)
    }

    func addCustomExtension() {
        guard let ext = ExtensionNormalizer.normalize(customExtensionInput) else {
            alertInfo = AlertInfo(
                title: "扩展名不合法",
                message: "请输入字母/数字开头，可包含 +、-、_，且不带多余符号。"
            )
            return
        }

        selectedExtensions.insert(ext)
        customExtensionInput = ""
        refreshAssociation(for: [ext])
    }

    func addExtensions(from urls: [URL]) {
        var recognized: Set<String> = []
        for url in urls {
            guard let ext = ExtensionNormalizer.normalize(url.pathExtension) else { continue }
            selectedExtensions.insert(ext)
            recognized.insert(ext)
        }

        guard !recognized.isEmpty else {
            alertInfo = AlertInfo(title: "未识别扩展名", message: "所选文件没有可识别的扩展名。")
            return
        }

        refreshAssociation(for: Array(recognized))
    }

    func handleDroppedProviders(_ providers: [NSItemProvider]) -> Bool {
        let fileProviders = providers.filter {
            $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
        }
        guard !fileProviders.isEmpty else {
            return false
        }

        for provider in fileProviders {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) {
                [weak self] item, _ in
                guard let self, let url = Self.extractFileURL(from: item) else {
                    return
                }

                Task { @MainActor in
                    self.addExtensions(from: [url])
                }
            }
        }

        return true
    }

    func apply() async {
        guard let app = selectedApp else {
            alertInfo = AlertInfo(title: "未选择应用", message: "请先在左侧选择一个应用。")
            return
        }

        guard let bundleID = app.bundleIdentifier, !bundleID.isEmpty else {
            alertInfo = AlertInfo(title: "应用不可用", message: "当前应用没有可用的 Bundle Identifier。")
            return
        }

        guard !selectedExtensions.isEmpty else {
            alertInfo = AlertInfo(title: "未选择扩展名", message: "请至少选择一个扩展名。")
            return
        }

        isApplying = true
        let extensions = selectedExtensionsSorted
        let results = extensions.map {
            associationService.setDefaultHandler(for: $0, bundleID: bundleID)
        }
        isApplying = false

        let successCount = results.filter(\.success).count
        let failures = results.filter { !$0.success }

        refreshAssociation(for: extensions)

        if failures.isEmpty {
            alertInfo = AlertInfo(
                title: "操作完成",
                message: "成功设置 \(successCount) 个扩展名到 \(app.name)。"
            )
            return
        }

        let detail =
            failures
            .map { "\(ExtensionNormalizer.display($0.ext))：\($0.message)" }
            .joined(separator: "\n")

        alertInfo = AlertInfo(
            title: "部分失败",
            message: "成功 \(successCount) 个，失败 \(failures.count) 个。\n\n\(detail)"
        )
    }

    private func refreshKnownExtensions() async {
        let known = Set(categories.flatMap(\.extensions))
        refreshAssociation(for: Array(known))
    }

    private func refreshAssociation(for extensions: [String]) {
        for ext in extensions {
            associationMap[ext] = associationService.queryCurrentHandler(for: ext)
        }
    }

    private func extensionsForToolbarGroup() -> [String] {
        if toolbarGroupID == "all" {
            return categories.flatMap(\.extensions)
        }
        guard let category = categories.first(where: { $0.id == toolbarGroupID }) else {
            return []
        }
        return category.extensions
    }

    nonisolated private static func extractFileURL(from item: NSSecureCoding?) -> URL? {
        if let data = item as? Data {
            return URL(dataRepresentation: data, relativeTo: nil)
        }
        if let url = item as? URL {
            return url
        }
        if let str = item as? String {
            return URL(string: str)
        }
        return nil
    }
}
