// Vista de perfil de usuario con configuracion de moneda y preferencias
// Muestra la informacion del usuario logueado, opciones de configuracion,
// seleccion de moneda principal y preferencia de conversion a VES.

import SwiftUI

/// Vista de perfil y configuracion del usuario al estilo nativo iOS 26
struct ProfileView: View {
    @ObservedObject private var authService = AuthService.shared
    @State private var showNotificationSettings = false
    @State private var showCurrencyPicker = false

    // Preferencias de usuario almacenadas localmente
    @AppStorage("preferredCurrency") private var preferredCurrency: String = "USD"
    @AppStorage("showVesConversion") private var showVesConversion: Bool = true

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Tarjeta del Usuario Actual
                    userCard

                    // Configuracion de Moneda
                    currencySection

                    // Bloque de Preferencias
                    preferencesSection

                    // Boton de Cerrar Sesion
                    signOutButton

                    // Version de la app
                    Text("Agenda Financiera v1.0")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.appleSecondary)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                }
            }
            .background(Color.appleBackground)
            .navigationTitle("Mi Perfil")
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        }
        .task {
            await authService.fetchUserProfile()
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView()
        }
    }

    // MARK: - Tarjeta de Usuario

    private var userCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.appleBlue.opacity(0.1))
                    .frame(width: 72, height: 72)

                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                    .foregroundStyle(Color.appleBlue)
            }

            if let user = authService.currentUser {
                VStack(spacing: 4) {
                    Text(user.full_name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.applePrimary)

                    Text(user.email)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appleSecondary)
                }
            } else {
                ProgressView()
                    .tint(Color.appleBlue)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .appleCardStyle()
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Configuracion de Moneda

    private var currencySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MONEDA")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.appleSecondary)
                .tracking(1.0)
                .padding(.leading, 28)

            VStack(spacing: 0) {
                // Moneda principal
                Button {
                    showCurrencyPicker = true
                } label: {
                    HStack(spacing: 14) {
                        SettingsRow(
                            icon: "dollarsign.circle.fill",
                            iconBgColor: .appleGreen,
                            title: "Moneda Principal"
                        )

                        Spacer()

                        Text(preferredCurrency)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appleBlue)
                            .padding(.trailing, 20)
                    }
                }
                .confirmationDialog("Seleccionar Moneda", isPresented: $showCurrencyPicker) {
                    ForEach(UserProfile.availableCurrencies, id: \.code) { currency in
                        Button("\(currency.symbol) \(currency.name) (\(currency.code))") {
                            preferredCurrency = currency.code
                        }
                    }
                    Button("Cancelar", role: .cancel) {}
                }

                Divider()
                    .padding(.leading, 56)

                // Conversion a VES
                Toggle(isOn: $showVesConversion) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.12))
                                .frame(width: 32, height: 32)

                            Image(systemName: "coloncurrencysign.circle.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.orange)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Conversion a Bolivares")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.applePrimary)
                            Text("Mostrar equivalente en VES con tasa BCV")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.appleSecondary)
                        }
                    }
                }
                .tint(Color.appleBlue)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
            }
            .appleCardStyle()
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Preferencias

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PREFERENCIAS")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.appleSecondary)
                .tracking(1.0)
                .padding(.leading, 28)

            VStack(spacing: 0) {
                Button { showNotificationSettings = true } label: {
                    SettingsRow(icon: "bell.fill", iconBgColor: .appleBlue, title: "Notificaciones")
                }

                Divider()
                    .padding(.leading, 56)

                Button { } label: {
                    SettingsRow(icon: "hand.raised.fill", iconBgColor: .appleGreen, title: "Privacidad y Seguridad")
                }

                Divider()
                    .padding(.leading, 56)

                Button { } label: {
                    SettingsRow(icon: "questionmark.circle.fill", iconBgColor: .appleSecondary, title: "Ayuda y Soporte")
                }
            }
            .appleCardStyle()
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Cerrar Sesion

    private var signOutButton: some View {
        Button {
            Task {
                try? await authService.signOut()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                    .font(.system(size: 16))
                Text("Cerrar Sesion")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(Color.appleRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .appleCardStyle()
            .padding(.horizontal, 20)
        }
    }
}

/// Fila reutilizable para las opciones de configuracion del perfil
struct SettingsRow: View {
    let icon: String
    let iconBgColor: Color
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconBgColor.opacity(0.12))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconBgColor)
            }

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.applePrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appleSecondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
    }
}
