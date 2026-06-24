// Servicio de presupuestos mensuales conectado a Supabase
// Gestiona la creacion, consulta y seguimiento de presupuestos por categoria.

import Foundation
import Combine
import Supabase

/// Servicio central para gestionar presupuestos mensuales del usuario en Supabase
@MainActor
public final class BudgetService: ObservableObject {
    @Published public var budgets: [Budget] = []
    @Published public var isLoading = false

    public static let shared = BudgetService()

    private let client = AppSupabaseClient.shared.client

    private init() {}

    // MARK: - Consultas

    /// Descarga los presupuestos del mes y anio indicados para el usuario logueado
    public func fetchBudgets(month: Int? = nil, year: Int? = nil) async {
        guard let session = try? await client.auth.session else { return }
        let userId = session.user.id

        let calendar = Calendar.current
        let currentMonth = month ?? calendar.component(.month, from: Date())
        let currentYear = year ?? calendar.component(.year, from: Date())

        isLoading = true
        do {
            let response: [Budget] = try await client
                .from("budgets")
                .select()
                .eq("user_id", value: userId)
                .eq("month", value: currentMonth)
                .eq("year", value: currentYear)
                .execute()
                .value

            self.budgets = response
            self.isLoading = false
        } catch {
            self.isLoading = false
            print("Error al descargar presupuestos de Supabase: \(error.localizedDescription)")
        }
    }

    // MARK: - Creacion

    /// Crea o actualiza un presupuesto para una categoria en el mes/anio actual
    public func saveBudget(categoryId: String, amount: Double, month: Int, year: Int) async -> Bool {
        guard let session = try? await client.auth.session else { return false }
        let userId = session.user.id

        let newBudget = Budget(
            id: UUID(),
            userId: userId,
            categoryId: categoryId,
            amount: amount,
            month: month,
            year: year
        )

        do {
            try await client
                .from("budgets")
                .upsert(newBudget)
                .execute()

            await fetchBudgets(month: month, year: year)
            return true
        } catch {
            print("Error al guardar presupuesto en Supabase: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Calculos

    /// Calcula el gasto total de una categoria en las transacciones del mes actual
    public func spentInCategory(_ categoryId: String, transactions: [Transaction]) -> Double {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())

        return transactions
            .filter { tx in
                tx.type == .expense &&
                tx.categoryId == categoryId &&
                calendar.component(.month, from: tx.date) == currentMonth &&
                calendar.component(.year, from: tx.date) == currentYear
            }
            .reduce(0) { $0 + $1.amount }
    }

    /// Calcula el porcentaje consumido del presupuesto de una categoria
    public func percentUsed(for categoryId: String, transactions: [Transaction]) -> Double {
        guard let budget = budgets.first(where: { $0.categoryId == categoryId }),
              budget.amount > 0 else {
            return 0
        }
        let spent = spentInCategory(categoryId, transactions: transactions)
        return min((spent / budget.amount) * 100.0, 100.0)
    }

    /// Calcula el presupuesto total del mes actual sumando todos los presupuestos activos
    public func totalBudget() -> Double {
        budgets.reduce(0) { $0 + $1.amount }
    }

    /// Limpia los datos locales del presupuesto al cerrar sesión
    public func clearData() {
        self.budgets = []
    }
}
