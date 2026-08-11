import Foundation
import CoreData
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadStoredSession()
    }

    // MARK: - Session
    private func loadStoredSession() {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        if let entity = try? context.fetch(request).first {
            currentUser = mapUser(from: entity)
            isAuthenticated = true
        }
    }

    // MARK: - Sign Up
    func signUp(name: String, email: String, password: String) {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email.lowercased())
        if let existing = try? context.fetch(request), !existing.isEmpty {
            errorMessage = "An account with this email already exists."
            return
        }

        isLoading = true
        let entity = UserEntity(context: context)
        entity.id = UUID()
        entity.name = name
        entity.email = email.lowercased()
        entity.passwordHash = simpleHash(password)
        entity.giftPoints = 50   // welcome bonus
        entity.joinDate = Date()

        PersistenceController.shared.save()
        currentUser = mapUser(from: entity)
        isAuthenticated = true
        isLoading = false
        errorMessage = nil
    }

    // MARK: - Login
    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }

        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email.lowercased())

        guard let entity = try? context.fetch(request).first else {
            errorMessage = "No account found with this email."
            return
        }

        guard entity.passwordHash == simpleHash(password) else {
            errorMessage = "Incorrect password."
            return
        }

        currentUser = mapUser(from: entity)
        isAuthenticated = true
        errorMessage = nil
    }

    // MARK: - Logout
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Update Gift Points
    func addGiftPoints(_ points: Int) {
        guard let user = currentUser else { return }
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
        if let entity = try? context.fetch(request).first {
            entity.giftPoints += Int32(points)
            PersistenceController.shared.save()
            currentUser = mapUser(from: entity)
        }
    }

    func deductGiftPoints(_ points: Int) {
        guard let user = currentUser else { return }
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
        if let entity = try? context.fetch(request).first {
            entity.giftPoints = max(0, entity.giftPoints - Int32(points))
            PersistenceController.shared.save()
            currentUser = mapUser(from: entity)
        }
    }

    func refreshUser() {
        guard let user = currentUser else { return }
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
        if let entity = try? context.fetch(request).first {
            currentUser = mapUser(from: entity)
        }
    }

    // MARK: - Helpers
    private func mapUser(from entity: UserEntity) -> User {
        User(
            id: entity.id ?? UUID(),
            name: entity.name ?? "User",
            email: entity.email ?? "",
            giftPoints: Int(entity.giftPoints),
            joinDate: entity.joinDate ?? Date()
        )
    }

    private func simpleHash(_ input: String) -> String {
        // Simple deterministic hash for demo — not for production
        var hash: UInt64 = 14695981039346656037
        for byte in input.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return String(hash, radix: 16)
    }
}
