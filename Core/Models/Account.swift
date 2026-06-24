import Foundation

/// Modelo Codable que representa una cuenta financiera en Supabase
public struct Account: Codable, Identifiable, Hashable {
    public let id: UUID
    public let userId: UUID
    public let name: String
    public let type: String // "checking", "savings", "credit", "cash", "crypto", "wallet"
    public var balance: Double
    public let accountNumber: String
    public let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case type
        case balance
        case accountNumber = "account_number"
        case createdAt = "created_at"
    }
    
    /// Moneda de la cuenta ("VES" o "USD"), inferida del prefijo del número de cuenta
    public var currency: String {
        if accountNumber.starts(with: "VES|") {
            return "VES"
        } else {
            return "USD"
        }
    }
    
    /// Número de cuenta limpio sin el prefijo de la moneda
    public var cleanAccountNumber: String {
        if accountNumber.contains("|") {
            let parts = accountNumber.split(separator: "|", maxSplits: 1)
            if parts.count > 1 {
                return String(parts[1])
            }
        }
        return accountNumber
    }
    
    /// Devuelve el saldo de la cuenta convertido a la moneda destino ("USD" o "VES") usando la tasa de cambio especificada
    public func balance(in targetCurrency: String, rate: Double) -> Double {
        if self.currency == targetCurrency {
            return balance
        }
        if self.currency == "VES" && targetCurrency == "USD" {
            return rate > 0 ? balance / rate : 0
        }
        if self.currency == "USD" && targetCurrency == "VES" {
            return balance * rate
        }
        return balance
    }
}
