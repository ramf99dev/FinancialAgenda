// Punto de entrada principal de la aplicacion
// Configura la inyeccion de dependencias, gestiona la sesion inicial
// y aplica el sistema de diseno unificado.

import SwiftUI
import Supabase

@main
struct AgendaFinancieraApp: App {
    @StateObject private var authService = AuthService.shared
    @StateObject private var accountService = AccountService.shared
    @StateObject private var txService = TransactionService.shared
    @StateObject private var rateService = ExchangeRateService.shared
    @StateObject private var categoryService = CategoryService.shared
    @StateObject private var budgetService = BudgetService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(accountService)
                .environmentObject(txService)
                .environmentObject(rateService)
                .environmentObject(categoryService)
                .environmentObject(budgetService)
                // Establece el color de fondo base para toda la aplicacion
                .background(Color.appleBackground)
                // Fuerza a que use los colores del entorno
                .preferredColorScheme(.none)
                .onAppear {
                    // Inicializar servicios necesarios al arranque
                    Task {
                        await rateService.fetchRates()
                    }
                }
        }
    }
}
