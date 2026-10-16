import Foundation

/// Обёртка над подписью IPA.
/// Сейчас это заглушка: сюда подключается zsign (C++), см. README.
enum Signer {
    enum SignError: LocalizedError {
        case notImplemented
        case missingPassword

        var errorDescription: String? {
            switch self {
            case .notImplemented: return "Подпись ещё не подключена (нужен zsign)."
            case .missingPassword: return "Не найден пароль сертификата в Keychain."
            }
        }
    }

    /// Подписывает IPA выбранным сертификатом и возвращает путь к новому IPA.
    /// - Parameters:
    ///   - ipa: исходный IPA
    ///   - cert: сертификат
    ///   - store: хранилище (путь к .p12/.mobileprovision и пароль)
    ///   - bundleID: новый bundle ID, если нужно сменить (nil = оставить)
    static func sign(ipa: IPAFile, cert: SigningCert, store: CertStore, bundleID: String?) async throws -> URL {
        guard let _ = await store.password(for: cert.id) else { throw SignError.missingPassword }

        // TODO (шаг 2): вызвать zsign через мост C++ <-> Swift:
        //   zsign -k cert.p12 -p <пароль> -m profile.mobileprovision -b <bundleID> -o out.ipa in.ipa
        // Пока просто сообщаем, что подпись не готова.
        throw SignError.notImplemented
    }
}
