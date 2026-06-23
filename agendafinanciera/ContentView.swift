// Vista de enrutamiento principal (Root)
// Decide si mostrar la pantalla de autenticacion o la aplicacion principal
// basandose en el estado de la sesion del usuario.

import SwiftUI

/// Controlador de vista principal que maneja el flujo de autenticacion vs app principal
struct ContentView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if authService.session != nil {
                AppMainContainerView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authService.session != nil)
        .onAppear {
            Task {
                await authService.checkSession()
            }
        }
    }
}
