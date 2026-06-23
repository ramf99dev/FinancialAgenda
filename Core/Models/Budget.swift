// Modelo de presupuesto mensual por categoria
// Permite al usuario establecer limites de gasto por categoria en un periodo mensual.
// Se conecta a la tabla "budgets" de Supabase.

import Foundation

/// Representa un presupuesto mensual asignado a una categoria especifica
public struct Budget: Identifiable, Codable {
    public let id: UUID
    public let userId: UUID
    public let categoryId: String
    public let amount: Double
    public let month: Int
    public let year: Int
    public let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case categoryId = "category_id"
        case amount
        case month
        case year
        case createdAt = "created_at"
    }

    public init(id: UUID, userId: UUID, categoryId: String, amount: Double, month: Int, year: Int, createdAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.categoryId = categoryId
        self.amount = amount
        self.month = month
        self.year = year
        self.createdAt = createdAt
    }
}
