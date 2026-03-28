import SwiftUI

struct MainOperationView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.categories) { category in
                            ExtensionCategorySection(
                                category: category,
                                selectedExtensions: viewModel.selectedExtensions,
                                associationMap: viewModel.associationMap,
                                toggleAction: viewModel.toggleExtension,
                                selectAllAction: { viewModel.selectAll(in: category) },
                                clearCategoryAction: { viewModel.clearCategory(in: category) }
                            )
                        }
                    }
                }
            }
            .padding(14)
            .liquidGlassCard(cornerRadius: 18, tint: .white, borderOpacity: 0.3)

            VStack(alignment: .leading, spacing: 10) {
                SelectedExtensionPanel(
                    selectedApp: viewModel.selectedApp,
                    selectedExtensions: viewModel.selectedExtensionsSorted,
                    isApplying: viewModel.isApplying,
                    canApply: viewModel.canApply,
                    removeAction: viewModel.removeSelectedExtension,
                    clearAction: viewModel.clearSelection,
                    applyAction: { Task { await viewModel.apply() } }
                )
            }
            .padding(14)
            .liquidGlassCard(cornerRadius: 18, tint: .white, borderOpacity: 0.3)
        }
    }
}

private struct ExtensionCategorySection: View {
    let category: ExtensionCategory
    let selectedExtensions: Set<String>
    let associationMap: [String: ExtensionAssociationInfo]
    let toggleAction: (String) -> Void
    let selectAllAction: () -> Void
    let clearCategoryAction: () -> Void

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 128), spacing: 8, alignment: .leading)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(category.title)
                    .font(.headline)
                Spacer()
                Button("全选", action: selectAllAction)
                Button("清空分类", action: clearCategoryAction)
            }

            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(category.extensions, id: \.self) { ext in
                    let info = associationMap[ext]
                    ExtensionChip(
                        ext: ext,
                        defaultHandlerName: info?.handlerAppName,
                        isSelected: selectedExtensions.contains(ext),
                        action: { toggleAction(ext) }
                    )
                }
            }
        }
        .padding(12)
    }
}

private struct ExtensionChip: View {
    let ext: String
    let defaultHandlerName: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(ExtensionNormalizer.display(ext))
                    .font(.subheadline.weight(.semibold))
                Text(defaultHandlerName ?? "暂无关联信息")
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .liquidGlassCard(
                cornerRadius: 9,
                tint: isSelected ? Color.accentColor : .white,
                borderOpacity: isSelected ? 0.8 : 0.35
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(isSelected ? Color.accentColor : Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SelectedExtensionPanel: View {
    let selectedApp: InstalledApp?
    let selectedExtensions: [String]
    let isApplying: Bool
    let canApply: Bool
    let removeAction: (String) -> Void
    let clearAction: () -> Void
    let applyAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("当前选中应用：\(selectedApp?.name ?? "未选择")")
                .font(.headline)
            Text("Bundle ID：\(selectedApp?.bundleIdentifier ?? "-")")
                .font(.caption)
                .foregroundStyle(.secondary)

            if selectedExtensions.isEmpty {
                Text("尚未选择扩展名")
                    .foregroundStyle(.secondary)
            } else {
                FlowLikeWrapView(items: selectedExtensions, removeAction: removeAction)
            }

            HStack {
                Button("清空选择", action: clearAction)
                Spacer()
                Button {
                    applyAction()
                } label: {
                    if isApplying {
                        HStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Applying...")
                        }
                    } else {
                        Text("Apply")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canApply)
            }
        }
    }
}

private struct FlowLikeWrapView: View {
    let items: [String]
    let removeAction: (String) -> Void

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 86), spacing: 8, alignment: .leading)]
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { ext in
                HStack(spacing: 4) {
                    Text(ExtensionNormalizer.display(ext))
                        .font(.subheadline)
                    Button {
                        removeAction(ext)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.22), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
