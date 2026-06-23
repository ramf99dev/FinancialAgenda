import Foundation
import Combine
import Supabase

/// Servicio central para gestionar las operaciones y transacciones reales de cada cliente en Supabase
@MainActor
public final class TransactionService: ObservableObject {
    @Published public var transactions: [Transaction] = []
    @Published public var isLoading = false
    
    public static let shared = TransactionService()
    
    private let client = AppSupabaseClient.shared.client
    private var realtimeChannel: RealtimeChannelV2? = nil
    
    private init() {
        // La suscripción en tiempo real se inicializa automáticamente al autenticarse
    }
    
    /// Descarga las transacciones del usuario logueado en orden cronológico inverso
    public func fetchTransactions() async {
        guard let session = try? await client.auth.session else { return }
        let userId = session.user.id
        
        isLoading = true
        do {
            let response: [Transaction] = try await client
                .from("transactions")
                .select()
                .eq("user_id", value: userId)
                .order("date", ascending: false)
                .execute()
                .value
            
            self.transactions = response
            self.isLoading = false
            
            // Habilitar escucha en tiempo real
            await subscribeToRealtimeTransactions()
        } catch {
            self.isLoading = false
            print("Error al descargar transacciones de Supabase: \(error.localizedDescription)")
        }
    }
    
    /// Guarda una operacion nueva en Supabase y actualiza de inmediato el saldo de la cuenta elegida
    public func saveTransaction(amount: Double, type: TransactionType, categoryId: String, note: String?, accountId: UUID) async -> String? {
        guard let session = try? await client.auth.session else { return "No hay sesión activa" }
        let userId = session.user.id
        
        let newTx = Transaction(
            id: UUID(),
            userId: userId,
            accountId: accountId,
            amount: amount,
            type: type,
            categoryId: categoryId,
            note: note,
            date: Date()
        )
        
        do {
            // 1. Guardar la transaccion en Supabase
            try await client
                .from("transactions")
                .insert(newTx)
                .execute()
            
            // 2. Despachar la actualizacion de saldo de la cuenta asociada de manera asincrona
            await AccountService.shared.updateAccountBalance(
                accountId: accountId,
                amount: amount,
                type: type
            )
            
            // Refrescar localmente
            await fetchTransactions()
            return nil
        } catch {
            let errorDetails = String(describing: error)
            print("Error al guardar transaccion en Supabase: \(errorDetails)")
            return error.localizedDescription + " (\(errorDetails))"
        }
    }
    
    /// Elimina una transaccion en Supabase y revierte el balance de la cuenta
    public func deleteTransaction(_ id: UUID, accountId: UUID?, amount: Double, type: TransactionType) async {
        do {
            try await client
                .from("transactions")
                .delete()
                .eq("id", value: id)
                .execute()
            
            // Si tiene cuenta asociada, revertimos el balance
            if let actId = accountId {
                // Para revertir, invertimos el tipo
                let reverseType: TransactionType = type == .income ? .expense : .income
                await AccountService.shared.updateAccountBalance(
                    accountId: actId,
                    amount: amount,
                    type: reverseType
                )
            }
            
            // Refrescar
            await fetchTransactions()
        } catch {
            print("Error al eliminar transaccion en Supabase: \(error.localizedDescription)")
        }
    }
    
    /// Suscribe a cambios en tiempo real en la tabla transactions
    public func subscribeToRealtimeTransactions() async {
        guard realtimeChannel == nil else { return }
        
        let channel = client.realtimeV2.channel("public-transactions-changes")
        
        _ = channel.onPostgresChange(
            AnyAction.self,
            schema: "public",
            table: "transactions"
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchTransactions()
            }
        }
        
        self.realtimeChannel = channel
        do {
            try await channel.subscribe()
        } catch {
            print("Error suscribiendo: \(error)")
        }
    }
    
    /// Cancela la suscripción en tiempo real
    public func unsubscribe() async {
        if let channel = realtimeChannel {
            await client.realtimeV2.removeChannel(channel)
            self.realtimeChannel = nil
        }
        self.transactions = []
    }
    
    /// Firma de compatibilidad temporal para evitar errores de compilacion intermedios
    public func saveTransaction(amount: Double, type: TransactionType, categoryId: String, note: String?, recurring: String?) {
        // Obtenemos la primera cuenta del usuario para no romper llamadas legacy si las hubiera
        Task {
            if let firstAccount = await AccountService.shared.accounts.first {
                _ = await saveTransaction(
                    amount: amount,
                    type: type,
                    categoryId: categoryId,
                    note: note,
                    accountId: firstAccount.id
                )
            }
        }
    }
}
