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
}
