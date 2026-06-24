// Fila individual de transaccion optimizada para el listado del historial
// Muestra el icono de categoria, nota, fecha relativa e importe
// usando las utilidades centralizadas del proyecto.

import SwiftUI

/// Fila visual de una transaccion individual con formato Apple minimalista
struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 14) {
            // Icono de Categoria con fondo circular
            ZStack {
                Circle()
                    .fill(transaction.category.color.opacity(0.1))
                    .frame(width: 42, height: 42)

                Image(systemName: transaction.category.iconName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(transaction.category.color)
            }

            // Nombre y fecha
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.note ?? transaction.category.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.applePrimary)
                    .lineLimit(1)

                Text(DateFormatHelper.relativeString(from: transaction.date))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appleSecondary)
            }

            Spacer()

            // Importe formateado
            Text(transaction.formattedAmount)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(transaction.type == .income ? Color.appleGreen : Color.appleRed)
                .lineLimit(1)
                .layoutPriority(1)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}
