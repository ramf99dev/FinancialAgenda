import SwiftUI

/// Tarjeta individual para mostrar cuentas en el carrusel horizontal con estetica Apple
struct BalanceCardView: View {
    let cardName: String
    let balance: Double
    let currencyCode: String
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icono de la cuenta
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(iconColor)
            }
            
            // Textos y saldo de la cuenta
            VStack(alignment: .leading, spacing: 4) {
                Text(cardName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.appleSecondary)
                    .lineLimit(1)
                
                Text(formattedAmount)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(balance >= 0 ? Color.applePrimary : Color.appleRed)
                    .lineLimit(1)
            }
        }
        .frame(width: 140, height: 120, alignment: .leading)
        .padding(16)
        .appleCardStyle()
    }
    
    private var formattedAmount: String {   
        if currencyCode == "VES" {
            return CurrencyFormatter.formatVES(balance)
        } else {
            return CurrencyFormatter.format(balance, currencyCode: currencyCode)
        }
    }
}

#Preview {
    HStack {
        BalanceCardView(cardName: "Cuenta Corriente", balance: 8300.0, currencyCode: "VES", iconName: "building.columns.fill", iconColor: Color.appleBlue)
        BalanceCardView(cardName: "Ahorros", balance: 3150.50, currencyCode: "USD", iconName: "leaf.fill", iconColor: Color.appleGreen)
    }
    .padding()
    .background(Color.appleBackground)
}
