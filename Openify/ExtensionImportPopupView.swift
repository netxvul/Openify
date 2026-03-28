import SwiftUI
import UniformTypeIdentifiers

struct ExtensionImportPopupView: View {
    @ObservedObject var viewModel: MainViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var showFileImporter = false
    @State private var isDropTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("导入文件扩展名")
                .font(.title3.weight(.semibold))

            Text("可点击选择文件，或直接拖拽文件到下方区域，系统会自动识别扩展名并加入已选列表。")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                showFileImporter = true
            } label: {
                Label("选择文件", systemImage: "folder.badge.plus")
            }
            .buttonStyle(.borderedProminent)

            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isDropTargeted ? Color.accentColor : Color.gray.opacity(0.45),
                    style: StrokeStyle(lineWidth: 1.2, dash: [6, 4])
                )
                .frame(height: 130)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "tray.and.arrow.down")
                            .font(.title2)
                        Text("拖拽文件到这里，自动识别扩展名")
                            .font(.callout)
                    }
                    .foregroundStyle(.secondary)
                }
                .onDrop(
                    of: [UTType.fileURL.identifier],
                    isTargeted: $isDropTargeted
                ) { providers in
                    viewModel.handleDroppedProviders(providers)
                }

            HStack {
                Spacer()
                Button("完成") {
                    dismiss()
                }
            }
        }
        .padding(18)
        .frame(width: 460)
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                viewModel.addExtensions(from: urls)
            case .failure(let error):
                viewModel.alertInfo = AlertInfo(
                    title: "选择文件失败",
                    message: error.localizedDescription
                )
            }
        }
    }
}
