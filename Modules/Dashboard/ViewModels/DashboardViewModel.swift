// ViewModel del Dashboard principal
// Coordina la carga de datos, calculos de salud financiera y totales consolidados.
// Extrae toda la logica de negocio de DashboardView para mantener la vista declarativa.

import SwiftUI
import Combine

/// ViewModel que gestiona el estado y la logica de negocio del Dashboard
@MainActor
public final class DashboardViewModel: ObservableObject {

    // MARK: - Servicios Observados

    @Published public var accountService = AccountService.shared
    @Published public var txService = TransactionService.shared
    @Published public var rateService = ExchangeRateService.shared
    @Published public var budgetService = BudgetService.shared
    @Published public var categoryService = CategoryService.shared

    // MARK: - Estado de la Vista

    @Published public var showAddSheet = false
    @Published public var showCreateAccountSheet = false
    @Published public var showCalculatorSheet = false
    @Published public var initialTransactionType: TransactionType = .expense
    @Published public var isLoading = false

    /// Moneda principal del usuario, leida de UserDefaults
    @Published public var preferredCurrency: String = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD"

    /// Indica si la conversion a VES esta habilitada
    @Published public var showVesConversion: Bool = UserDefaults.standard.object(forKey: "showVesConversion") as? Bool ?? true

    private var cancellables = Set<AnyCancellable>()

    public init() {
        // Propagar actualizaciones de AccountService para redibujar la vista
        AccountService.shared.$accounts
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Propagar actualizaciones de TransactionService
        TransactionService.shared.$transactions
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Propagar actualizaciones de ExchangeRateService
        ExchangeRateService.shared.$bcvRate
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Propagar actualizaciones de BudgetService
        BudgetService.shared.$budgets
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Propiedades Computadas de Balance

    /// Saldo consolidado de todas las cuentas del usuario
    public var totalBalance: Double {
        let rate = rateService.bcvRate
        return accountService.accounts.reduce(0) { sum, account in
            sum + account.balance(in: preferredCurrency, rate: rate)
        }
    }

    /// Total de ingresos registrados en todas las transacciones
    public var totalIncomes: Double {
        let rate = rateService.bcvRate
        let accounts = accountService.accounts
        return txService.transactions
            .filter { $0.type == .income }
            .reduce(0) { sum, tx in
                sum + tx.amount(in: preferredCurrency, rate: rate, accounts: accounts)
            }
    }

    /// Total de egresos registrados en todas las transacciones
    public var totalExpenses: Double {
        let rate = rateService.bcvRate
        let accounts = accountService.accounts
        return txService.transactions
            .filter { $0.type == .expense }
            .reduce(0) { sum, tx in
                sum + tx.amount(in: preferredCurrency, rate: rate, accounts: accounts)
            }
    }

    /// Flujo neto: ingresos menos egresos
    public var netFlow: Double {
        totalIncomes - totalExpenses
    }

    // MARK: - Salud Financiera

    /// Puntaje de salud financiera entre 0 y 100 basado en flujo de caja y cobertura
    public var financialHealthScore: Double {
        if txService.transactions.isEmpty && accountService.accounts.isEmpty {
            return 100.0
        }

        let cashFlowPoints: Double
        if totalIncomes > 0 {
            let savingsRate = (totalIncomes - totalExpenses) / totalIncomes
            if savingsRate >= 0.20 {
                cashFlowPoints = 100.0
            } else if savingsRate >= 0 {
                cashFlowPoints = 50.0 + (savingsRate / 0.20) * 50.0
            } else {
                cashFlowPoints = max(0.0, 50.0 + (savingsRate * 50.0))
            }
        } else {
            cashFlowPoints = totalExpenses > 0 ? 0.0 : (totalBalance >= 0 ? 100.0 : 0.0)
        }

        let coveragePoints: Double
        if totalExpenses > 0 {
            let coverageRatio = totalBalance / totalExpenses
            if coverageRatio >= 3.0 {
                coveragePoints = 100.0
            } else if coverageRatio > 0 {
                coveragePoints = (coverageRatio / 3.0) * 100.0
            } else {
                coveragePoints = 0.0
            }
        } else {
            if totalBalance > 0 {
                coveragePoints = 100.0
            } else if totalBalance == 0 {
                coveragePoints = 50.0
            } else {
                coveragePoints = 0.0
            }
        }

        let rawScore = (cashFlowPoints * 0.6) + (coveragePoints * 0.4)
        return min(max(rawScore, 0.0), 100.0)
    }

    /// Clasificacion textual del estado de salud financiera
    public var financialHealthStatus: String {
        let score = financialHealthScore
        if score >= 80 { return "Excelente" }
        if score >= 50 { return "Estable" }
        if score >= 30 { return "En Riesgo" }
        return "Critica"
    }

    /// Color semantico asociado al estado de salud financiera
    public var financialHealthColor: Color {
        let score = financialHealthScore
        if score >= 80 { return .appleGreen }
        if score >= 50 { return .appleBlue }
        if score >= 30 { return .orange }
        return .appleRed
    }

    /// Recomendacion personalizada segun el puntaje
    public var financialHealthRecommendation: String {
        let score = financialHealthScore
        if score >= 80 { return "Tus finanzas estan solidas. Excelente habito de ahorro y cobertura." }
        if score >= 50 { return "Finanzas estables. Intenta reducir gastos hormiga para mejorar." }
        if score >= 30 { return "Gastos elevados. Te recomendamos armar un presupuesto estricto." }
        return "Alerta de deficit. Intenta reducir gastos o incrementar ingresos."
    }

    // MARK: - Carga de Datos

    /// Carga todos los datos necesarios para el Dashboard de manera concurrente
    public func loadDashboardData() async {
        // Sincronizar preferencias del usuario desde UserDefaults
        self.preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD"
        self.showVesConversion = UserDefaults.standard.object(forKey: "showVesConversion") as? Bool ?? true
        
        isLoading = true
        
        async let accountsFetch: () = accountService.fetchAccounts()
        async let txFetch: () = txService.fetchTransactions()
        async let categoriesFetch: () = categoryService.fetchCategories()
        async let budgetsFetch: () = budgetService.fetchBudgets()

        // Esperar únicamente por los datos críticos de la estructura
        _ = await (accountsFetch, txFetch, categoriesFetch, budgetsFetch)
        
        // Quitar la pantalla de esqueleto de inmediato para un renderizado ultra veloz
        isLoading = false
        
        // Cargar tasas de cambio en segundo plano sin interrumpir al usuario
        Task {
            await rateService.fetchRates()
        }
    }

    // MARK: - Formateo

    /// Formatea un saldo en la moneda preferida del usuario
    public func formatBalance(_ value: Double) -> String {
        CurrencyFormatter.format(value, currencyCode: preferredCurrency)
    }

    /// Formatea un saldo en Bolivares
    public func formatVesBalance(_ value: Double) -> String {
        CurrencyFormatter.formatVES(value)
    }
}
