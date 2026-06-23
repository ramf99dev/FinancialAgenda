import Foundation
import Combine
import Supabase

/// Servicio unificado para gestionar las cuentas bancarias reales de cada cliente en Supabase
@MainActor
public final class AccountService: ObservableObject {
    @Published public var accounts: [Account] = []
    @Published public var isLoading = false
    
    public static let shared = AccountService()
    
    private let client = AppSupabaseClient.shared.client
    private var realtimeChannel: RealtimeChannelV2? = nil
    
    private init() {
        // La suscripción en tiempo real se iniciará automáticamente al autenticarse
    }
    
    /// Obtiene las cuentas del usuario logueado desde la base de datos
    public func fetchAccounts() async {
        guard let session = try? await client.auth.session else { return }
        let userId = session.user.id
        
        isLoading = true
        do {
            let response: [Account] = try await client
                .from("accounts")
                .select()
                .eq("user_id", value: userId)
                .order("created_at")
                .execute()
                .value
            
            self.accounts = response
            self.isLoading = false
            
            // Suscribirse al canal en tiempo real
            await subscribeToRealtimeAccounts()
        } catch {
            self.isLoading = false
            print("Error al descargar cuentas de Supabase: \(error.localizedDescription)")
        }
    }
    
    /// Inserta una nueva cuenta en la base de datos Supabase
    public func createAccount(name: String, type: String, initialBalance: Double) async -> Bool {
        guard let session = try? await client.auth.session else { return false }
        let userId = session.user.id
        
        let actNumber: String
        switch type {
        case "cash":
            actNumber = "Efectivo Físico"
        case "crypto":
            actNumber = "Billetera Binance"
        case "wallet":
            actNumber = "Billetera Digital"
        default:
            actNumber = "**** \(Int.random(in: 1000...9999))"
        }
        
        let newAccount = Account(
            id: UUID(),
            userId: userId,
            name: name,
            type: type,
            balance: initialBalance,
            accountNumber: actNumber,
            createdAt: nil
        )
        
        do {
            try await client
                .from("accounts")
                .insert(newAccount)
                .execute()
            
            // Refrescar localmente
            await fetchAccounts()
            return true
        } catch {
            print("Error al crear cuenta en Supabase: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Actualiza el saldo de una cuenta especifica tras registrar una operacion
    public func updateAccountBalance(accountId: UUID, amount: Double, type: TransactionType) async {
        guard let accountIndex = accounts.firstIndex(where: { $0.id == accountId }) else { return }
        var account = accounts[accountIndex]
        
        if type == .income {
            account.balance += amount
        } else {
            account.balance -= amount
        }
        
        do {
            try await client
                .from("accounts")
                .update(["balance": account.balance])
                .eq("id", value: accountId)
                .execute()
            
            // Actualizar localmente la coleccion de manera inmediata
            self.accounts[accountIndex] = account
        } catch {
            print("Error al actualizar saldo de cuenta en Supabase: \(error.localizedDescription)")
        }
    }
    
    /// Suscribe la aplicacion a actualizaciones en tiempo real de la tabla accounts
    public func subscribeToRealtimeAccounts() async {
        guard realtimeChannel == nil else { return }
        
        let channel = client.realtimeV2.channel("public-accounts-changes")
        
        _ = channel.onPostgresChange(
            AnyAction.self,
            schema: "public",
            table: "accounts"
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchAccounts()
            }
        }
        
        self.realtimeChannel = channel
        do {
            try await channel.subscribe()
        } catch {
            print("Error suscribiendo al canal de realtime: \(error)")
        }
    }
    
    /// Elimina una cuenta de la base de datos
    public func deleteAccount(_ id: UUID) async {
        do {
            try await client
                .from("accounts")
                .delete()
                .eq("id", value: id)
                .execute()
                
            await fetchAccounts()
        } catch {
            print("Error al eliminar cuenta en Supabase: \(error.localizedDescription)")
        }
    }
    
    /// Cancela la suscripción en tiempo real al cerrar sesión
    public func unsubscribe() async {
        if let channel = realtimeChannel {
            await client.realtimeV2.removeChannel(channel)
            self.realtimeChannel = nil
        }
        self.accounts = []
    }
}
