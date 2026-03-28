import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showImportPopup = false

    var body: some View {
        NavigationSplitView {
            AppSidebarView(
                apps: viewModel.filteredApps,
                selectedAppID: $viewModel.selectedAppID,
                searchText: $viewModel.searchText,
                isLoading: viewModel.isLoadingApps,
                reloadAction: { Task { await viewModel.reloadApps() } }
            )
            .frame(minWidth: 260, idealWidth: 280)
            .padding(10)
            .liquidGlassCard(cornerRadius: 18, tint: .white, borderOpacity: 0.32)
        } detail: {
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                    .ignoresSafeArea()

                MainOperationView(viewModel: viewModel)
                    .padding(10)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 980, minHeight: 640)
        .background(WindowChromeConfigurator())
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Picker("扩展名分组", selection: $viewModel.toolbarGroupID) {
                    ForEach(viewModel.toolbarGroups) { group in
                        Text(group.title).tag(group.id)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 130)

                Button("全选分组") {
                    viewModel.selectAllInToolbarGroup()
                }

                Button("清空分组") {
                    viewModel.clearToolbarGroupSelection()
                }

                Button {
                    showImportPopup = true
                } label: {
                    Label("导入文件", systemImage: "tray.and.arrow.down")
                }

                TextField("添加扩展名", text: $viewModel.customExtensionInput)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
                    .onSubmit(viewModel.addCustomExtension)

                Button {
                    viewModel.addCustomExtension()
                } label: {
                    Image(systemName: "plus")
                }
                .help("添加扩展名")

                Button("清空全部") {
                    viewModel.clearSelection()
                }
            }
        }
        .alert(item: $viewModel.alertInfo) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showImportPopup) {
            ExtensionImportPopupView(viewModel: viewModel)
        }
        .task {
            await viewModel.bootstrap()
        }
    }
}

#Preview {
    ContentView()
}
