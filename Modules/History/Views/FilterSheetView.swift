import SwiftUI

/// Vista modal de filtrado avanzado de transacciones al estilo Apple claro
struct FilterSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var minAmount: Double
    @Binding var maxAmount: Double
    @Binding var transactionType: TransactionType?
    
    var body: some View {
        ZStack {
            Color.appleBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                // Cabecera superior
                HStack {
                    Text("Filtrar Resultados")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.applePrimary)
                    Spacer()
                    Button("Listo") { dismiss() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appleBlue)
                }
                
                // Tipo de flujo selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("TIPO DE FLUJO")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.appleSecondary)
                        .tracking(1.0)
                        
                    HStack(spacing: 12) {
                        Button {
                            transactionType = transactionType == .income ? nil : .income
                        } label: {
                            Text("Solo Ingresos")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(transactionType == .income ? Color.appleBlue.opacity(0.12) : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(transactionType == .income ? Color.appleBlue : Color.appleLightGray, lineWidth: 1)
                                )
                                .foregroundStyle(transactionType == .income ? Color.appleBlue : Color.applePrimary)
                                .appleShadow()
                        }
                        
                        Button {
                            transactionType = transactionType == .expense ? nil : .expense
                        } label: {
                            Text("Solo Egresos")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(transactionType == .expense ? Color.appleBlue.opacity(0.12) : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(transactionType == .expense ? Color.appleBlue : Color.appleLightGray, lineWidth: 1)
                                )
                                .foregroundStyle(transactionType == .expense ? Color.appleBlue : Color.applePrimary)
                                .appleShadow()
                        }
                    }
                }
                
                // Rango de importes
                VStack(alignment: .leading, spacing: 12) {
                    Text("RANGO DE IMPORTES")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.appleSecondary)
                        .tracking(1.0)
                        
                    Slider(value: $maxAmount, in: 0...5000, step: 50)
                        .tint(Color.appleBlue)
                    
                    HStack {
                        Text("Hasta: $\(String(format: "%.0f", maxAmount))")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.applePrimary)
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding(.all, 24)
        }
    }
}
