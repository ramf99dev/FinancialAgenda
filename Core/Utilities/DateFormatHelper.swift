// Utilidad centralizada de formateo de fechas relativas y agrupacion temporal
// Provee cadenas de fecha legibles en espanol y logica de agrupacion por seccion.

import Foundation

/// Formateador reutilizable de fechas con soporte para formato relativo y agrupacion
public enum DateFormatHelper {

    // MARK: - Fecha Relativa

    /// Genera una cadena de fecha relativa legible en espanol (Hoy, Ayer, fecha completa)
    public static func relativeString(from date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.locale = Locale(identifier: "es")
            return "Hoy, \(formatter.string(from: date))"
        }

        if calendar.isDateInYesterday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.locale = Locale(identifier: "es")
            return "Ayer, \(formatter.string(from: date))"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, h:mm a"
        formatter.locale = Locale(identifier: "es")
        return formatter.string(from: date)
    }

    // MARK: - Agrupacion por Seccion

    /// Identificador de seccion para agrupar transacciones por periodo temporal
    public enum SectionGroup: String, Comparable {
        case today = "Hoy"
        case yesterday = "Ayer"
        case thisWeek = "Esta Semana"
        case thisMonth = "Este Mes"
        case older = "Anteriores"

        /// Orden de prioridad para las secciones: las mas recientes primero
        private var sortOrder: Int {
            switch self {
            case .today:     return 0
            case .yesterday: return 1
            case .thisWeek:  return 2
            case .thisMonth: return 3
            case .older:     return 4
            }
        }

        public static func < (lhs: SectionGroup, rhs: SectionGroup) -> Bool {
            lhs.sortOrder < rhs.sortOrder
        }
    }

    /// Determina a que seccion temporal pertenece una fecha dada
    public static func sectionGroup(for date: Date) -> SectionGroup {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return .today
        }
        if calendar.isDateInYesterday(date) {
            return .yesterday
        }

        // Verificar si pertenece a esta semana
        if let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start,
           date >= weekStart {
            return .thisWeek
        }

        // Verificar si pertenece a este mes
        if calendar.isDate(date, equalTo: Date(), toGranularity: .month) {
            return .thisMonth
        }

        return .older
    }

    /// Formatea una fecha corta para encabezados de seccion
    public static func sectionHeader(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es")
        formatter.dateFormat = "EEEE, d 'de' MMMM"
        return formatter.string(from: date).capitalized
    }
}
