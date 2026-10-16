import Foundation
import Security

/// Хранит сертификаты: файлы в Documents/Certs, пароли в Keychain.
@MainActor
final class CertStore: ObservableObject {
    @Published var certs: [SigningCert] = []

    private let fm = FileManager.default
    private var root: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Certs")
    }
    private var indexURL: URL { root.appendingPathComponent("index.json") }

    init() { load() }

    // MARK: - Добавление

    func add(name: String, p12: URL, password: String, profile: URL) throws {
        var cert = SigningCert(name: name, p12FileName: "cert.p12", profileFileName: "profile.mobileprovision")
        let dir = root.appendingPathComponent(cert.id.uuidString)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)

        _ = p12.startAccessingSecurityScopedResource()
        _ = profile.startAccessingSecurityScopedResource()
        defer {
            p12.stopAccessingSecurityScopedResource()
            profile.stopAccessingSecurityScopedResource()
        }
        try fm.copyItem(at: p12, to: dir.appendingPathComponent(cert.p12FileName))
        try fm.copyItem(at: profile, to: dir.appendingPathComponent(cert.profileFileName))

        try savePassword(password, for: cert.id)
        cert.status = .unknown
        certs.append(cert)
        save()
    }

    func remove(_ cert: SigningCert) {
        try? fm.removeItem(at: directory(for: cert))
        deletePassword(for: cert.id)
        certs.removeAll { $0.id == cert.id }
        save()
    }

    // MARK: - Пути

    func directory(for cert: SigningCert) -> URL {
        root.appendingPathComponent(cert.id.uuidString)
    }
    func p12URL(for cert: SigningCert) -> URL { directory(for: cert).appendingPathComponent(cert.p12FileName) }
    func profileURL(for cert: SigningCert) -> URL { directory(for: cert).appendingPathComponent(cert.profileFileName) }

    // MARK: - Индекс

    private func load() {
        try? fm.createDirectory(at: root, withIntermediateDirectories: true)
        guard let data = try? Data(contentsOf: indexURL),
              let list = try? JSONDecoder().decode([SigningCert].self, from: data) else { return }
        certs = list
    }

    private func save() {
        if let data = try? JSONEncoder().encode(certs) { try? data.write(to: indexURL) }
    }

    // MARK: - Keychain

    func password(for id: UUID) -> String? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: id.uuidString,
            kSecReturnData as String: true
        ]
        var out: AnyObject?
        guard SecItemCopyMatching(q as CFDictionary, &out) == errSecSuccess,
              let data = out as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func savePassword(_ pw: String, for id: UUID) throws {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: id.uuidString,
            kSecValueData as String: Data(pw.utf8)
        ]
        let status = SecItemAdd(q as CFDictionary, nil)
        guard status == errSecSuccess else { throw NSError(domain: "Keychain", code: Int(status)) }
    }

    private func deletePassword(for id: UUID) {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: id.uuidString
        ]
        SecItemDelete(q as CFDictionary)
    }
}
