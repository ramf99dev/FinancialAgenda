// Contenedor principal de navegacion con TabView nativo iOS 26
// Gestiona la navegacion entre los modulos principales de la aplicacion
// usando el TabBar nativo con Liquid Glass incorporado de iOS 26.

import SwiftUI

/// Contenedor principal que administra la navegacion entre modulos de la aplicacion
struct AppMainContainerView: View {
    @State private var activeTab: AppTab = .dashboard
    @State private var showAddTransactionSheet = false

    /// Pestanas disponibles en la aplicacion
    enum AppTab: Hashable {
        case dashboard
        case history
        case add
        case accounts
        case profile
    }

    var body: some View {
        TabView(selection: tabSelection) {
            // Pestana: Dashboard / Inicio
            Tab("Inicio", systemImage: "house.fill", value: AppTab.dashboard) {
                DashboardView()
            }

            // Pestana: Historial de Actividad
            Tab("Historial", systemImage: "chart.bar.fill", value: AppTab.history) {
                HistoryView()
            }

            // Pestana: Agregar Transaccion (interceptada como modal)
            Tab("Agregar", systemImage: "plus.circle.fill", value: AppTab.add) {
                // Vista placeholder, la navegacion real abre un sheet
                Color.clear
            }

            // Pestana: Resumen de Cuentas
            Tab("Cuentas", systemImage: "creditcard.fill", value: AppTab.accounts) {
                AccountsSummaryView()
            }

            // Pestana: Perfil y Configuracion
            Tab("Perfil", systemImage: "person.fill", value: AppTab.profile) {
                ProfileView()
            }
        }
        .sheet(isPresented: $showAddTransactionSheet) {
            AddTransactionView()
        }
    }

    /// Binding personalizado que intercepta la seleccion de la pestana "Agregar"
    /// para abrir el modal en lugar de navegar a una vista
    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { activeTab },
            set: { newTab in
                if newTab == .add {
                    showAddTransactionSheet = true
                } else {
                    activeTab = newTab
                }
            }
        )
    }
}
