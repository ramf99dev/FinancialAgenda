import Foundation

/// Tipo de transaccion disponible
public enum TransactionType: String, Codable, CaseIterable {
    case income = "income"
    case expense = "expense"
}

/// Representa un registro de transaccion codificable conectado a Supabase
public struct Transaction: Identifiable, Codable {
    public let id: UUID
    public let userId: UUID
    public let accountId: UUID?
    public let amount: Double
    public let type: TransactionType
    public let categoryId: String
    public let note: String?
    public let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case accountId = "account_id"
        case amount
        case type
        case categoryId = "category"
        case note
        case date
    }
    
    public init(id: UUID, userId: UUID, accountId: UUID?, amount: Double, type: TransactionType, categoryId: String, note: String?, date: Date) {
        self.id = id
        self.userId = userId
        self.accountId = accountId
        self.amount = amount
        self.type = type
        self.categoryId = categoryId
        self.note = note
        self.date = date
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.userId = try container.decode(UUID.self, forKey: .userId)
        self.accountId = try container.decodeIfPresent(UUID.self, forKey: .accountId)
        self.amount = try container.decode(Double.self, forKey: .amount)
        self.type = try container.decode(TransactionType.self, forKey: .type)
        self.categoryId = try container.decode(String.self, forKey: .categoryId)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        
        if let dateString = try? container.decode(String.self, forKey: .date) {
            if let decodedDate = Self.parseDate(dateString) {
                self.date = decodedDate
            } else {
                self.date = Date()
            }
        } else if let dateDouble = try? container.decode(Double.self, forKey: .date) {
            self.date = Date(timeIntervalSince1970: dateDouble)
        } else {
            self.date = Date()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(amount, forKey: .amount)
        try container.encode(type, forKey: .type)
        try container.encode(categoryId, forKey: .categoryId)
        try container.encode(note, forKey: .note)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(formatter.string(from: date), forKey: .date)
    }
    
    private static func parseDate(_ string: String) -> Date? {
        let isoFormatterWithFractional = ISO8601DateFormatter()
        isoFormatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatterWithFractional.date(from: string) {
            return date
        }
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: string) {
            return date
        }
        
        let formats = [
            "yyyy-MM-dd HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        
        return nil
    }
    
    public var category: Category {
        CategoryService.shared.categories.first(where: { $0.id == categoryId })
            ?? Category.all.first(where: { $0.id == categoryId })
            ?? Category.other
    }
    
    /// Devuelve el monto de la transaccion convertido a la moneda destino ("USD" o "VES") segun la cuenta asociada
    public func amount(in targetCurrency: String, rate: Double, accounts: [Account]) -> Double {
        guard let accountId = accountId, let account = accounts.first(where: { $0.id == accountId }) else {
            // Si no tiene cuenta asociada, asumimos que está en USD
            if targetCurrency == "VES" {
                return amount * rate
            }
            return amount
        }
        
        let txCurrency = account.currency
        if txCurrency == targetCurrency {
            return amount
        }
        if txCurrency == "VES" && targetCurrency == "USD" {
            return rate > 0 ? amount / rate : 0
        }
        if txCurrency == "USD" && targetCurrency == "VES" {
            return amount * rate
        }
        return amount
    }

    /// Formatea el monto en la moneda nativa de la cuenta asociada
    public func formattedAmount(accounts: [Account]) -> String {
        guard let accountId = accountId, let account = accounts.first(where: { $0.id == accountId }) else {
            return (type == .income ? "+" : "-") + CurrencyFormatter.format(amount)
        }
        let prefix = type == .income ? "+" : "-"
        let formatted = account.currency == "VES" ? CurrencyFormatter.formatVES(amount) : CurrencyFormatter.format(amount)
        return prefix + formatted
    }

    public var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        let prefix = type == .income ? "+" : "-"
        return prefix + (formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)")
    }
    
    public static let mockList: [Transaction] = []
}
