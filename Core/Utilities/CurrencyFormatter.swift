// Formateador centralizado de moneda y cantidades numericas
// Provee formateo consistente para USD, VES y la moneda preferida del usuario
// a lo largo de toda la aplicacion.

import Foundation

/// Formateador reutilizable de cantidades monetarias
public enum CurrencyFormatter {

    // MARK: - Moneda Principal

    /// Formatea un valor numerico como moneda en el codigo ISO especificado (por defecto USD)
    public static func format(_ value: Double, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(currencyCode) \(value)"
    }

    /// Formatea un valor en Bolivares venezolanos con el prefijo "Bs."
    public static func formatVES(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        if let formatted = formatter.string(from: NSNumber(value: value)) {
            return "Bs. \(formatted)"
        }
        return "Bs. \(value)"
    }

    /// Formatea un valor con signo explicito de ingreso (+) o egreso (-)
    public static func formatSigned(_ value: Double, type: TransactionType, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        let prefix = type == .income ? "+" : "-"
        return prefix + (formatter.string(from: NSNumber(value: value)) ?? "\(currencyCode) \(value)")
    }

    /// Formatea un valor de manera compacta para widgets (ej: "$1.2K", "$3.5M")
    public static func formatCompact(_ value: Double, currencyCode: String = "USD") -> String {
        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""
        let symbol = currencySymbol(for: currencyCode)

        if absValue >= 1_000_000 {
            let formatted = formatDecimal(absValue / 1_000_000, minimumFractionDigits: 1, maximumFractionDigits: 1)
            return "\(sign)\(symbol)\(formatted)M"
        } else if absValue >= 1_000 {
            let formatted = formatDecimal(absValue / 1_000, minimumFractionDigits: 1, maximumFractionDigits: 1)
            return "\(sign)\(symbol)\(formatted)K"
        }
        return format(value, currencyCode: currencyCode)
    }

    /// Formatea un valor decimal genérico con separador de miles '.' y decimal ','
    public static func formatDecimal(_ value: Double, minimumFractionDigits: Int = 2, maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    // MARK: - Auxiliares

    /// Devuelve el simbolo de moneda para un codigo ISO
    private static func currencySymbol(for code: String) -> String {
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: .currencySymbol, value: code) ?? "$"
    }
}
