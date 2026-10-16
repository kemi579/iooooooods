import SwiftUI
import UniformTypeIdentifiers

struct CertsView: View {
    @EnvironmentObject var store: CertStore
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.certs) { cert in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(cert.name).font(.headline)
                            Text(cert.addedAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        StatusBadge(status: cert.status)
                    }
                }
                .onDelete { idx in idx.map { store.certs[$0] }.forEach(store.remove) }
            }
            .overlay {
                if store.certs.isEmpty {
                    ContentUnavailableView("Нет сертификатов", systemImage: "key",
                                           description: Text("Нажми + и добавь .p12 и .mobileprovision"))
                }
            }
            .navigationTitle("Сертификаты")
            .toolbar {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showAdd) { AddCertView() }
        }
    }
}

struct StatusBadge: View {
    let status: CertStatus
    var body: some View {
        let (text, color): (String, Color) = switch status {
        case .unknown: ("не проверен", .gray)
        case .valid: ("действителен", .green)
        case .revoked: ("отозван", .red)
        case .expired: ("истёк", .orange)
        }
        Text(text).font(.caption2).padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.2)).foregroundStyle(color).clipShape(Capsule())
    }
}

struct AddCertView: View {
    @EnvironmentObject var store: CertStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var password = ""
    @State private var p12: URL?
    @State private var profile: URL?
    @State private var picking: Picking?
    @State private var error: String?

    enum Picking: Identifiable { case p12, profile; var id: Int { hashValue } }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название", text: $name)
                SecureField("Пароль от .p12", text: $password)
                Button(p12?.lastPathComponent ?? "Выбрать .p12") { picking = .p12 }
                Button(profile?.lastPathComponent ?? "Выбрать .mobileprovision") { picking = .profile }
                if let error { Text(error).foregroundStyle(.red) }
            }
            .navigationTitle("Новый сертификат")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить", action: save).disabled(name.isEmpty || p12 == nil || profile == nil)
                }
            }
            .fileImporter(isPresented: Binding(get: { picking != nil }, set: { if !$0 { picking = nil } }),
                          allowedContentTypes: [.item]) { result in
                if case .success(let url) = result {
                    if picking == .p12 { p12 = url } else { profile = url }
                }
            }
        }
    }

    private func save() {
        guard let p12, let profile else { return }
        do {
            try store.add(name: name, p12: p12, password: password, profile: profile)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
