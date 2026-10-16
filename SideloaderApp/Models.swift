import Foundation

/// Один сертификат: .p12 + пароль + профиль провижининга.
struct SigningCert: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String            // имя, которое видит пользователь
    var p12FileName: String     // файл лежит в Documents/Certs/<id>/
    var profileFileName: String // .mobileprovision рядом
    var addedAt = Date()
    var status: CertStatus = .unknown
}

enum CertStatus: String, Codable {
    case unknown   // ещё не проверяли
    case valid     // действителен
    case revoked   // отозван Apple
    case expired   // истёк срок
}

/// IPA, добавленный пользователем.
struct IPAFile: Identifiable, Hashable {
    var id = UUID()
    var url: URL
    var name: String { url.deletingPathExtension().lastPathComponent }
}
