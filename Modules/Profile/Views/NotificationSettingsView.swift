import SwiftUI

/// Vista de configuracion de alertas y limites con estetica Apple
struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var alertPercent = 80.0
    @State private var dailySummary = true
    @State private var instantExpenses = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appleBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Encabezado Informativo
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PREFERENCIAS DE ALERTA")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.appleSecondary)
                                .tracking(1.0)
                            Text("Configuración de Notificaciones")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.applePrimary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            // Alertas de Egreso Instantaneo
                            Toggle(isOn: $instantExpenses) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Alertas de Gasto Instantáneas")
                                        .foregroundStyle(Color.applePrimary)
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Notificarme inmediatamente tras cualquier egreso.")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.appleSecondary)
                                }
                            }
                            .tint(Color.appleBlue)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .appleCardStyle()
                            
                            // Informe Diario inteligente
                            Toggle(isOn: $dailySummary) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Informe de Cierre Diario")
                                        .foregroundStyle(Color.applePrimary)
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Resumen inteligente consolidado del balance del día.")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.appleSecondary)
                                }
                            }
                            .tint(Color.appleGreen)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .appleCardStyle()
                            
                            // Slider de Alerta de Presupuesto
                            VStack(alignment: .leading, spacing: 14) {
                                Text("ALERTA DE LÍMITE DE PRESUPUESTO")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.appleSecondary)
                                    .tracking(1.0)
                                
                                HStack {
                                    Text("Notificar al alcanzar el:")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(Color.applePrimary)
                                    Spacer()
                                    Text("\(Int(alertPercent))%")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.appleBlue)
                                }
                                
                                Slider(value: $alertPercent, in: 50...100, step: 5)
                                    .tint(Color.appleBlue)
                            }
                            .padding(20)
                            .appleCardStyle()
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appleBlue)
                }
            }
        }
    }
}

#Preview {
    NotificationSettingsView()
}
