// Vista de historial de actividad con filtrado avanzado y agrupacion temporal
// Muestra las transacciones del usuario organizadas por secciones de fecha
// con soporte para busqueda, filtros por categoria/tipo y eliminacion con swipe.

import SwiftUI

/// Vista de historial de movimientos con filtrado avanzado y estetica Apple minimalista
struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @ObservedObject private var categoryService = CategoryService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filtros horizontales de categoria
                categoryFilterBar

                // Filtros de tipo (Ingresos / Egresos)
                if viewModel.hasActiveFilters {
                    filteredTotalBanner
                }

                // Contenido principal
                if viewModel.filteredTransactions.isEmpty {
                    emptyState
                } else {
                    transactionsList
                }
            }
            .background(Color.appleBackground)
            .navigationTitle("Historial")
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .searchable(text: $viewModel.searchPattern, prompt: "Buscar por nota o categoria...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Filtro por tipo
                        Section("Tipo de operacion") {
                            Button {
                                viewModel.activeTypeFilter = nil
                            } label: {
                                Label("Todos", systemImage: viewModel.activeTypeFilter == nil ? "checkmark" : "")
                            }
                            Button {
                                viewModel.activeTypeFilter = .income
                            } label: {
                                Label("Solo Ingresos", systemImage: viewModel.activeTypeFilter == .income ? "checkmark" : "")
                            }
                            Button {
                                viewModel.activeTypeFilter = .expense
                            } label: {
                                Label("Solo Egresos", systemImage: viewModel.activeTypeFilter == .expense ? "checkmark" : "")
                            }
                        }

                        if viewModel.hasActiveFilters {
                            Section {
                                Button(role: .destructive) {
                                    viewModel.clearFilters()
                                } label: {
                                    Label("Limpiar Filtros", systemImage: "xmark.circle")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundStyle(Color.appleBlue)
                    }
                }
            }
        }
        .task {
            await viewModel.loadTransactions()
        }
        .alert("Eliminar Transaccion", isPresented: .init(
            get: { viewModel.transactionToDelete != nil },
            set: { if !$0 { viewModel.transactionToDelete = nil } }
        )) {
            Button("Cancelar", role: .cancel) {
                viewModel.transactionToDelete = nil
            }
            Button("Eliminar", role: .destructive) {
                if let tx = viewModel.transactionToDelete {
                    Task { await viewModel.deleteTransaction(tx) }
                }
            }
        } message: {
            if let tx = viewModel.transactionToDelete {
                Text("Se eliminara \"\(tx.note ?? tx.category.name)\" por \(tx.formattedAmount). Esta accion no se puede deshacer.")
            }
        }
    }

    // MARK: - Filtros de Categoria

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Opcion: Todos
                FilterChip(
                    label: "Todos",
                    isSelected: viewModel.activeCategoryFilter == nil,
                    color: .appleBlue
                ) {
                    viewModel.activeCategoryFilter = nil
                }

                ForEach(categoryService.categories) { cat in
                    FilterChip(
                        label: cat.name,
                        icon: cat.iconName,
                        isSelected: viewModel.activeCategoryFilter == cat.id,
                        color: cat.color
                    ) {
                        viewModel.activeCategoryFilter = cat.id
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Banner de Total Filtrado

    private var filteredTotalBanner: some View {
        HStack {
            Text("Resultado filtrado:")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.appleSecondary)
            Spacer()
            Text(CurrencyFormatter.format(viewModel.filteredTotal))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(viewModel.filteredTotal >= 0 ? Color.appleGreen : Color.appleRed)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color.appleBackground)
    }

    // MARK: - Estado Vacio

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(Color.appleSecondary.opacity(0.5))

            Text("No se encontraron transacciones")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.appleSecondary)

            if viewModel.hasActiveFilters {
                Button("Limpiar Filtros") {
                    viewModel.clearFilters()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appleBlue)
            }
            Spacer()
        }
    }

    // MARK: - Lista de Transacciones Agrupadas

    private var transactionsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.groupedTransactions, id: \.section) { group in
                    Section {
                        VStack(spacing: 0) {
                            ForEach(Array(group.transactions.enumerated()), id: \.element.id) { index, tx in
                                TransactionRowView(transaction: tx)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            viewModel.transactionToDelete = tx
                                        } label: {
                                            Label("Eliminar", systemImage: "trash.fill")
                                        }
                                    }

                                if index < group.transactions.count - 1 {
                                    Divider()
                                        .padding(.leading, 76)
                                }
                            }
                        }
                        .appleCardStyle()
                        .padding(.horizontal, 20)
                    } header: {
                        HStack {
                            Text(group.section.rawValue)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.appleSecondary)
                                .textCase(.uppercase)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 6)
                        .background(Color.appleBackground)
                    }
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Chip de Filtro Reutilizable

/// Boton de filtro en forma de capsula para seleccion de categorias
private struct FilterChip: View {
    let label: String
    var icon: String? = nil
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.12) : Color.appleSurface)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(isSelected ? color : Color.appleLightGray, lineWidth: 1)
            )
            .foregroundStyle(isSelected ? color : Color.applePrimary)
        }
    }
}
