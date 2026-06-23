// Modelo actualizado de usuario con soporte para multi-moneda
// Representa la configuracion de perfil del usuario en la aplicacion
// incluyendo la moneda principal seleccionada y la conversion a VES opcional.

import Foundation

/// Perfil de configuracion del usuario con preferencias de moneda
struct UserProfile: Identifiable, Codable {
    let id: UUID
    let email: String
    let fullname: String
    let avatarUrl: String?
    /// Codigo ISO de la moneda principal seleccionada (ej: "USD", "EUR", "MXN")
    var currency: String
    /// Presupuesto mensual global opcional del usuario
    var monthlyBudget: Double?
    /// Indica si la autenticacion biometrica esta habilitada
    var biometricAuthEnabled: Bool
    /// Indica si se debe mostrar la conversion a Bolivares (VES) en el Dashboard
    var showVesConversion: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullname
        case avatarUrl = "avatar_url"
        case currency
        case monthlyBudget = "monthly_budget"
        case biometricAuthEnabled = "biometric_auth_enabled"
        case showVesConversion = "show_ves_conversion"
    }

    /// Perfil con valores por defecto para nuevos usuarios
    static let defaultProfile = UserProfile(
        id: UUID(),
        email: "",
        fullname: "Usuario",
        avatarUrl: nil,
        currency: "USD",
        monthlyBudget: nil,
        biometricAuthEnabled: false,
        showVesConversion: true
    )

    /// Monedas disponibles para seleccion en la configuracion
    static let availableCurrencies: [(code: String, name: String, symbol: String)] = [
        ("USD", "Dolar Estadounidense", "$"),
        ("EUR", "Euro", "E"),
        ("MXN", "Peso Mexicano", "$"),
        ("COP", "Peso Colombiano", "$"),
        ("ARS", "Peso Argentino", "$"),
        ("BRL", "Real Brasileno", "R$"),
        ("CLP", "Peso Chileno", "$"),
        ("PEN", "Sol Peruano", "S/"),
        ("DOP", "Peso Dominicano", "$"),
        ("VES", "Bolivar Venezolano", "Bs.")
    ]
}
