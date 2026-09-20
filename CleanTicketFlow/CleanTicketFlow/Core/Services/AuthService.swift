//
//  AuthService.swift
//  CleanTicketFlow
//
//  Created by David Mclean on 9/10/26.
//

import CryptoKit
import Foundation

final class AuthService {

    static let shared = AuthService()

    // email → (hash, salt, roleKey)
    private var store: [String: (hash: String, salt: String, roleKey: String)] = [:]

    private init() {
        seedDemoUsers()
    }

    // MARK: - Public

    /// Returns the matching UserRole if credentials are valid, nil otherwise.
    func authenticate(email: String, password: String) -> UserRole? {
        let key = email.lowercased().trimmingCharacters(in: .whitespaces)
        guard let record = store[key] else { return nil }
        guard hash(password, salt: record.salt) == record.hash else { return nil }
        return role(from: record.roleKey)
    }

    // MARK: - Hashing

    /// SHA-256 of (password + salt). The salt ensures identical passwords
    /// produce different hashes across accounts.
    private func hash(_ password: String, salt: String) -> String {
        let data = Data((password + salt).utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Seeding

    /// Demo credentials — plaintext is used once here to derive the hash,
    /// then never referenced again. Only the hash and salt are retained.
    private func seedDemoUsers() {
        let users: [(email: String, password: String, salt: String, roleKey: String)] = [
            ("test@test.com",       "Atm$2026!", "aas-custodian-7f3k",   "custodian"),
            ("dispatcher@test.com", "Atm$2026!", "aas-dispatcher-2m9p",  "dispatcher"),
            ("technician@test.com", "Atm$2026!", "aas-technician-5q1r",  "technician:240230")
        ]
        for u in users {
            store[u.email] = (hash: hash(u.password, salt: u.salt),
                              salt: u.salt,
                              roleKey: u.roleKey)
        }
    }

    // MARK: - Role Mapping

    private func role(from key: String) -> UserRole? {
        switch key {
        case "custodian":  return .custodian
        case "dispatcher": return .dispatcher
        default:
            guard key.hasPrefix("technician:"),
                  let idStr = key.split(separator: ":").last,
                  let id = Int(idStr),
                  let tech = SampleData.technician(id: id) else { return nil }
            return .technician(tech)
        }
    }
}
