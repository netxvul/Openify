import SwiftUI

struct AppSidebarView: View {
    let apps: [InstalledApp]
    @Binding var selectedAppID: String?
    @Binding var searchText: String
    let isLoading: Bool
    let reloadAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                TextField("搜索应用名称", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Text("应用列表")
                        .font(.headline)
                    Spacer()
                    Button("刷新") {
                        reloadAction()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 6)

            if isLoading && apps.isEmpty {
                Spacer()
                ProgressView("扫描应用中...")
                Spacer()
            } else {
                List(selection: $selectedAppID) {
                    ForEach(apps) { app in
                        AppRowView(app: app)
                            .tag(app.id)
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }
        }
        .padding(.bottom, 10)
    }
}

private struct AppRowView: View {
    let app: InstalledApp

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 24, height: 24)
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .lineLimit(1)
                Text(app.bundleIdentifier ?? "Bundle Identifier 不可用")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
    }
}
