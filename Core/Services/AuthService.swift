import Foundation
import Supabase
import SwiftUI
import Combine

@MainActor
public final class AuthService: ObservableObject {
    public static let shared = AuthService()
    
    // Esta es la propiedad que ContentView busca
    @Published public var session: Session? = nil
    @Published public var currentUser: AppUser? = nil
    
    private let client = AppSupabaseClient.shared.client
    
    private init() {
        // Inicializa la sesión si ya existe
        Task { await checkSession() }
    }
    
    public func checkSession() async {
        self.session = try? await client.auth.session
    }
    
    // Métodos que faltaban
    public func signIn(email: String, password: String) async throws {
        self.session = try await client.auth.signIn(email: email, password: password)
    }
    
    public func signUp(email: String, password: String, fullName: String) async throws {
        _ = try await client.auth.signUp(
            email: email, 
            password: password, 
            data: ["full_name": .string(fullName)]
        )
    }
    
    public func sendPasswordReset(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    public func signOut() async throws {
        try await client.auth.signOut()
        self.session = nil
        self.currentUser = nil
        
        // Limpiar datos locales y cancelar suscripciones en tiempo real
        await AccountService.shared.unsubscribe()
        await TransactionService.shared.unsubscribe()
        await CategoryService.shared.unsubscribe()
        BudgetService.shared.clearData()
    }
    
    /// Obtiene y decodifica el perfil del usuario actual desde Supabase
    public func fetchUserProfile() async {
        guard let session = try? await client.auth.session else { return }
        let user = session.user
        
        var fullName = "Usuario"
        if let jsonValue = user.userMetadata["full_name"] {
            switch jsonValue {
            case .string(let val):
                fullName = val
            default:
                break
            }
        }
        
        var avatarUrl: String? = nil
        if let jsonValue = user.userMetadata["avatar_url"] {
            switch jsonValue {
            case .string(let val):
                avatarUrl = val
            default:
                break
            }
        }
        
        self.currentUser = AppUser(
            id: user.id,
            email: user.email ?? "",
            full_name: fullName,
            avatar_url: avatarUrl,
            fcm_token: nil,
            created_at: user.createdAt
        )
    }
}
