// Sistema de Diseno Unificado - Agenda Financiera
// Define la paleta de colores, modificadores de vista y estilos reutilizables
// para toda la aplicacion. Soporta modo claro y oscuro de manera adaptativa.

import SwiftUI

// MARK: - Namespace del Sistema de Diseno

/// Punto de acceso centralizado para estilos y utilidades visuales de la aplicacion
public enum AppStyle {

    /// Convierte un codigo hexadecimal a Color de SwiftUI
    public static func hex(_ hex: String) -> Color {
        Color.hex(hex)
    }
}

// MARK: - Paleta de Colores Personalizada

extension Color {

    // -- Fondos --
    /// Fondo principal de la aplicacion, adaptativo a modo claro/oscuro
    static let appleBackground = Color(light: Color(red: 242/255, green: 243/255, blue: 248/255),
                                        dark: Color(red: 0/255, green: 0/255, blue: 0/255))

    /// Superficie de tarjetas y contenedores
    static let appleSurface = Color(light: Color.white,
                                     dark: Color(red: 28/255, green: 28/255, blue: 30/255))

    // -- Texto --
    /// Color primario de texto
    static let applePrimary = Color(light: Color(red: 28/255, green: 28/255, blue: 30/255),
                                     dark: Color.white)

    /// Color secundario de texto y elementos de soporte
    static let appleSecondary = Color(light: Color(red: 142/255, green: 142/255, blue: 147/255),
                                       dark: Color(red: 174/255, green: 174/255, blue: 178/255))

    // -- Acento --
    /// Azul principal de la marca, para botones y enlaces
    static let appleBlue = Color(red: 0/255, green: 122/255, blue: 255/255)

    /// Verde de exito e ingresos
    static let appleGreen = Color(red: 52/255, green: 199/255, blue: 89/255)

    /// Rojo de error, alerta y egresos
    static let appleRed = Color(red: 255/255, green: 59/255, blue: 48/255)

    // -- Auxiliares --
    /// Gris claro para bordes y separadores
    static let appleLightGray = Color(light: Color(red: 216/255, green: 216/255, blue: 216/255),
                                       dark: Color(red: 56/255, green: 56/255, blue: 58/255))

    /// Tarjeta semi-transparente para overlays
    static let appleCard = Color(light: Color.white.opacity(0.7),
                                  dark: Color(red: 28/255, green: 28/255, blue: 30/255).opacity(0.7))

    /// Acento de la marca para elementos decorativos
    static let appleAccent = Color(red: 50/255, green: 65/255, blue: 45/255)

    // MARK: - Conversion de Hexadecimal a Color

    /// Resuelve un codigo hexadecimal de 6 caracteres a un Color de SwiftUI
    static func hex(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        return Color(red: r, green: g, blue: b)
    }
}

// MARK: - Inicializador Adaptativo Claro/Oscuro

extension Color {

    /// Crea un color que se adapta automaticamente segun el esquema de color del sistema
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

// MARK: - Modificadores de Vista Reutilizables

extension View {

    /// Estilo de tarjeta Apple: fondo blanco/oscuro, esquinas redondeadas y sombra sutil
    public func appleCardStyle(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(Color.appleSurface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    /// Estilo de campo de texto con fondo gris claro y esquinas redondeadas
    public func appleTextFieldStyle() -> some View {
        self
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.appleBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    /// Efecto de cristal liquido para tarjetas con material translucido
    public func liquidGlassCard(cornerRadius: CGFloat = 24) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    /// Sombra sutil estandar de Apple para elementos elevados
    public func appleShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
