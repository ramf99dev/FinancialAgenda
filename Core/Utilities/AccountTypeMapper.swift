// Mapeador centralizado de tipos de cuenta financiera

import SwiftUI

/// Resolucion centralizada de iconografia y color para tipos de cuenta financiera
public enum AccountTypeMapper {

    /// Devuelve el nombre del icono SF Symbol correspondiente al tipo de cuenta
    public static func icon(for type: String) -> String {
        switch type {
        case "checking": return "building.columns.fill"
        case "savings":  return "leaf.fill"
        case "credit":   return "creditcard.fill"
        case "cash":     return "banknote.fill"
        case "crypto":   return "bitcoinsign.circle.fill"
        case "wallet":   return "wallet.pass.fill"
        default:         return "circle.grid.2x2.fill"
        }
    }

    /// Devuelve el color semantico correspondiente al tipo de cuenta
    public static func color(for type: String) -> Color {
        switch type {
        case "checking": return .appleBlue
        case "savings":  return .appleGreen
        case "credit":   return .appleRed
        case "cash":     return .appleGreen
        case "crypto":   return .orange
        case "wallet":   return .purple
        default:         return .appleSecondary
        }
    }

    /// Devuelve el nombre legible para mostrar en la interfaz
    public static func displayName(for type: String) -> String {
        switch type {
        case "checking": return "Banco / Corriente"
        case "savings":  return "Ahorros"
        case "credit":   return "Tarjeta de Credito"
        case "cash":     return "Efectivo"
        case "crypto":   return "Binance / Cripto"
        case "wallet":   return "Billetera Digital"
        default:         return "Otra"
        }
    }
}
