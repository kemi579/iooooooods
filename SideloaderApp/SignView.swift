import SwiftUI

struct SignView: View {
    @EnvironmentObject var store: CertStore

    @State private var ipa: IPAFile?
    @State private var selectedCert: SigningCert?
    @State private var bundleID = ""
    @State private var showPicker = false
    @State private var busy = false
    @State private var message: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("IPA") {
                    Button(ipa?.url.lastPathComponent ?? "Выбрать IPA") { showPicker = true }
                }
                Section("Сертификат") {
                    Picker("Сертификат", selection: $selectedCert) {
                        Text("—").tag(SigningCert?.none)
                        ForEach(store.certs) { Text($0.name).tag(Optional($0)) }
                    }
                }
                Section("Bundle ID (необязательно)") {
                    TextField("com.example.app", text: $bundleID)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Section {
                    Button(action: sign) {
                        if busy { ProgressView() } else { Text("Подписать и установить") }
                    }
                    .disabled(ipa == nil || selectedCert == nil || busy)
                }
                if let message { Section { Text(message).font(.footnote) } }
            }
            .navigationTitle("Подпись")
            .fileImporter(isPresented: $showPicker, allowedContentTypes: [.item]) { result in
                if case .success(let url) = result { ipa = IPAFile(url: url) }
            }
        }
    }

    private func sign() {
        guard let ipa, let cert = selectedCert else { return }
        busy = true; message = nil
        Task {
            do {
                let out = try await Signer.sign(ipa: ipa, cert: cert, store: store,
                                                bundleID: bundleID.isEmpty ? nil : bundleID)
                message = "Готово: \(out.lastPathComponent)"
                // TODO (шаг 3): раздать через локальный HTTPS и открыть itms-services://
            } catch {
                message = error.localizedDescription
            }
            busy = false
        }
    }
}
