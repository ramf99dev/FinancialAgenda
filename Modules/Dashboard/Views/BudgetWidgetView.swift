// Widget compacto de presupuesto mensual para el Dashboard
// Muestra el progreso del presupuesto global del mes actual
// con indicador circular animado y alerta visual al superar el 80%.

import SwiftUI

/// Widget visual de resumen de presupuesto mensual para la pantalla principal
struct BudgetWidgetView: View {
    let totalBudget: Double
    let totalSpent: Double

    /// Porcentaje consumido del presupuesto (0 a 100+)
    private var percentUsed: Double {
        guard totalBudget > 0 else { return 0 }
        return (totalSpent / totalBudget) * 100.0
    }

    /// Color semantico segun el porcentaje de consumo
    private var progressColor: Color {
        if percentUsed >= 90 { return .appleRed }
        if percentUsed >= 70 { return .orange }
        return .appleGreen
    }

    /// Monto restante disponible
    private var remaining: Double {
        max(totalBudget - totalSpent, 0)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Indicador circular de progreso
            ZStack {
                Circle()
                    .stroke(Color.appleLightGray, lineWidth: 4)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: min(CGFloat(percentUsed / 100.0), 1.0))
                    .stroke(
                        progressColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: percentUsed)

                Text("\(Int(min(percentUsed, 999)))%")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.applePrimary)
            }

            // Textos informativos
            VStack(alignment: .leading, spacing: 4) {
                Text("Presupuesto del Mes")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.applePrimary)

                if totalBudget > 0 {
                    Text("Disponible: \(CurrencyFormatter.format(remaining))")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.appleSecondary)
                } else {
                    Text("Sin presupuesto configurado")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.appleSecondary)
                }
            }

            Spacer()

            // Indicador de alerta cuando supera el 80%
            if percentUsed >= 80 && totalBudget > 0 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.orange)
            }
        }
        .padding(16)
        .appleCardStyle()
    }
}
