import SwiftUI

/// Representa una categoria de transacciones con sus iconos y codigos de color
public struct Category: Identifiable, Codable, Hashable {
    public let id: String
    public let userId: UUID?
    public let name: String
    public let iconName: String
    public let hexColor: String
    
    public init(id: String, userId: UUID? = nil, name: String, iconName: String, hexColor: String) {
        self.id = id
        self.userId = userId
        self.name = name
        self.iconName = iconName
        self.hexColor = hexColor
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case iconName = "icon_name"
        case hexColor = "hex_color"
    }
    
    /// Resuelve dinamicamente el color segun el codigo hexadecimal de la base de datos
    public var color: Color {
        AppStyle.hex(hexColor)
    }
    
    public static let salary = Category(id: "salary", userId: nil, name: "Salario", iconName: "briefcase.fill", hexColor: "34C759")
    public static let food = Category(id: "food", userId: nil, name: "Alimentos", iconName: "fork.knife", hexColor: "FF9500")
    public static let transport = Category(id: "transport", userId: nil, name: "Transporte", iconName: "car.fill", hexColor: "007AFF")
    public static let housing = Category(id: "housing", userId: nil, name: "Vivienda", iconName: "house.fill", hexColor: "AF52DE")
    public static let entertainment = Category(id: "entertainment", userId: nil, name: "Ocio", iconName: "gamecontroller.fill", hexColor: "FF2D55")
    public static let invest = Category(id: "invest", userId: nil, name: "Inversiones", iconName: "chart.line.uptrend.xyaxis", hexColor: "5AC8FA")
    public static let other = Category(id: "other", userId: nil, name: "Otros", iconName: "cube.fill", hexColor: "8E8E93")
    
    public static let all: [Category] = [.salary, .food, .transport, .housing, .entertainment, .invest, .other]
}

