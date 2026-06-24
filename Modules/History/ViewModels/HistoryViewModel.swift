// ViewModel del Historial de Transacciones
// Gestiona el filtrado avanzado, busqueda, agrupacion por secciones temporales
// y la eliminacion de transacciones con confirmacion.

import SwiftUI
import Combine

/// ViewModel que gestiona el estado y la logica de filtrado del historial de actividad
@MainActor
public final class HistoryViewModel: ObservableObject {

    // MARK: - Servicios

    @Published public var txService = TransactionService.shared
    @Published public var accountService = AccountService.shared

    private var cancellables = Set<AnyCancellable>()

    public init() {
        // Propagar actualizaciones de TransactionService para redibujar la vista
        TransactionService.shared.$transactions
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Propagar actualizaciones de AccountService
        AccountService.shared.$accounts
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Estado de Filtros

    /// Patron de texto para busqueda por nota o negocio
    @Published public var searchPattern = ""

    /// Filtro de categoria activa, nil para mostrar todas
    @Published public var activeCategoryFilter: String? = nil

    /// Filtro de tipo de transaccion, nil para mostrar ambos
    @Published public var activeTypeFilter: TransactionType? = nil

    /// Fecha inicial del rango de filtro, nil para sin limite inferior
    @Published public var startDate: Date? = nil

    /// Fecha final del rango de filtro, nil para sin limite superior
    @Published public var endDate: Date? = nil

    // MARK: - Estado de Vista

    /// Transaccion seleccionada para eliminar (confirmacion)
    @Published public var transactionToDelete: Transaction? = nil

    /// Indica si se esta procesando la eliminacion
    @Published public var isDeleting = false

    // MARK: - Transacciones Filtradas

    /// Devuelve las transacciones aplicando todos los filtros activos
    public var filteredTransactions: [Transaction] {
        txService.transactions.filter { tx in
            // Filtro de busqueda por texto
            let matchesSearch = searchPattern.isEmpty ||
                (tx.note?.localizedCaseInsensitiveContains(searchPattern) ?? false) ||
                tx.category.name.localizedCaseInsensitiveContains(searchPattern)

            // Filtro de categoria
            let matchesCategory = activeCategoryFilter == nil || tx.categoryId == activeCategoryFilter

            // Filtro de tipo
            let matchesType = activeTypeFilter == nil || tx.type == activeTypeFilter

            // Filtro de rango de fechas
            let matchesDateRange: Bool
            if let start = startDate, let end = endDate {
                matchesDateRange = tx.date >= start && tx.date <= end
            } else if let start = startDate {
                matchesDateRange = tx.date >= start
            } else if let end = endDate {
                matchesDateRange = tx.date <= end
            } else {
                matchesDateRange = true
            }

            return matchesSearch && matchesCategory && matchesType && matchesDateRange
        }
    }

    /// Transacciones agrupadas por seccion temporal (Hoy, Ayer, Esta semana, etc.)
    public var groupedTransactions: [(section: DateFormatHelper.SectionGroup, transactions: [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { tx in
            DateFormatHelper.sectionGroup(for: tx.date)
        }
        return grouped
            .map { (section: $0.key, transactions: $0.value) }
            .sorted { $0.section < $1.section }
    }

    /// Total acumulado de las transacciones filtradas
    public var filteredTotal: Double {
        filteredTransactions.reduce(0) { total, tx in
            tx.type == .income ? total + tx.amount : total - tx.amount
        }
    }

    /// Indica si hay algun filtro activo
    public var hasActiveFilters: Bool {
        !searchPattern.isEmpty ||
        activeCategoryFilter != nil ||
        activeTypeFilter != nil ||
        startDate != nil ||
        endDate != nil
    }

    // MARK: - Acciones

    /// Carga las transacciones desde Supabase
    public func loadTransactions() async {
        await txService.fetchTransactions()
    }

    /// Elimina una transaccion y revierte el saldo de la cuenta asociada
    public func deleteTransaction(_ transaction: Transaction) async {
        isDeleting = true
        await txService.deleteTransaction(
            transaction.id,
            accountId: transaction.accountId,
            amount: transaction.amount,
            type: transaction.type
        )
        isDeleting = false
        transactionToDelete = nil
    }

    /// Limpia todos los filtros activos
    public func clearFilters() {
        searchPattern = ""
        activeCategoryFilter = nil
        activeTypeFilter = nil
        startDate = nil
        endDate = nil
    }
}
