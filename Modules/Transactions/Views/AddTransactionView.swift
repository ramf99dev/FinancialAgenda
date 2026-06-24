// Vista modal para registrar una nueva transaccion financiera
// Presenta un formulario optimizado con teclado numerico personalizado,
// seleccion de cuenta, categoria y fecha. Usa TransactionViewModel para la logica.

import SwiftUI

/// Vista modal de registro de operaciones financieras
struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = TransactionViewModel()

    let preselectedType: TransactionType

    init(preselectedType: TransactionType = .expense) {
        self.preselectedType = preselectedType
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appleBackground.ignoresSafeArea()

                VStack(spacing: 16) {
                    // Tipo de Operacion
                    Picker("Tipo", selection: $viewModel.selectedType) {
                        Text("Egreso").tag(TransactionType.expense)
                        Text("Ingreso").tag(TransactionType.income)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    .onChange(of: viewModel.selectedType) { newType in
                        viewModel.onTypeChanged(newType)
                    }

                    // Selector de Cuenta
                    if !viewModel.accounts.isEmpty {
                        accountSelector
                    }

                    // Visor del importe
                    amountDisplay

                    // Nota descriptiva
                    HStack(spacing: 12) {
                        Image(systemName: "pencil.line")
                            .foregroundStyle(Color.appleSecondary)
                        TextField("Agregar nota o descripcion...", text: $viewModel.note)
                            .foregroundStyle(Color.applePrimary)
                    }
                    .appleTextFieldStyle()
                    .padding(.horizontal, 20)

                    // Selector de Categoria
                    categorySelector

                    Spacer()

                    // Vista previa del saldo proyectado
                    if let projected = viewModel.projectedBalance {
                        HStack {
                            Text("Saldo tras operacion:")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.appleSecondary)
                            Spacer()
                            let formattedProjected = viewModel.selectedAccountCurrency == "VES" ? CurrencyFormatter.formatVES(projected) : CurrencyFormatter.format(projected)
                            Text(formattedProjected)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(projected >= 0 ? Color.appleGreen : Color.appleRed)
                        }
                        .padding(.horizontal, 24)
                    }

                    // Teclado Numerico
                    numericKeypad
                }
            }
            .navigationTitle("Nueva Operacion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundStyle(Color.appleSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(Color.appleBlue)
                    } else {
                        Button("Guardar") {
                            Task {
                                let success = await viewModel.saveTransaction()
                                if success { dismiss() }
                            }
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(viewModel.isFormValid ? Color.appleBlue : Color.appleSecondary)
                        .disabled(!viewModel.isFormValid)
                    }
                }
            }
        }
        .disabled(viewModel.isSaving)
        .task {
            viewModel.configure(preselectedType: preselectedType)
            await viewModel.loadCategories()
        }
        .sheet(isPresented: $viewModel.showCreateCategorySheet) {
            CreateCategoryView()
        }
        .alert("Error de Base de Datos", isPresented: $viewModel.showErrorAlert) {
            Button("Aceptar", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    // MARK: - Selector de Cuenta

    private var accountSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CUENTA")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.appleSecondary)
                .tracking(1.0)
                .padding(.leading, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.accounts) { account in
                        let isSelected = viewModel.selectedAccountId == account.id
                        Button {
                            viewModel.selectedAccountId = account.id
                            UISelectionFeedbackGenerator().selectionChanged()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: AccountTypeMapper.icon(for: account.type))
                                    .font(.caption)
                                Text(account.name)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(isSelected ? Color.appleBlue.opacity(0.12) : Color.appleSurface)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(isSelected ? Color.appleBlue : Color.appleLightGray, lineWidth: 1)
                            )
                            .foregroundStyle(isSelected ? Color.appleBlue : Color.applePrimary)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Visor del Importe

    private var amountDisplay: some View {
        VStack(spacing: 4) {
            Text("IMPORTE")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.appleSecondary)
                .tracking(1.0)

            let displayAmount = viewModel.amountString.replacingOccurrences(of: ".", with: ",")
            let currencySymbol = viewModel.selectedAccountCurrency == "VES" ? "Bs. " : "$"
            Text("\(currencySymbol)\(displayAmount)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(viewModel.selectedType == .income ? Color.appleGreen : Color.appleRed)
                .contentTransition(.numericText())
        }
        .padding(.vertical, 4)
    }

    // MARK: - Selector de Categoria

    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CATEGORIA")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.appleSecondary)
                .tracking(1.0)
                .padding(.leading, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.categoryService.categories) { category in
                        let isSelected = viewModel.selectedCategoryId == category.id
                        Button {
                            viewModel.selectedCategoryId = category.id
                            UISelectionFeedbackGenerator().selectionChanged()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: category.iconName)
                                    .font(.system(size: 13))
                                Text(category.name)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(isSelected ? category.color.opacity(0.12) : Color.appleSurface)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(isSelected ? category.color : Color.appleLightGray, lineWidth: 1)
                            )
                            .foregroundStyle(isSelected ? category.color : Color.applePrimary)
                        }
                    }

                    // Boton para agregar nueva categoria
                    Button {
                        viewModel.showCreateCategorySheet = true
                        UISelectionFeedbackGenerator().selectionChanged()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 13))
                            Text("Nueva")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(Color.appleSurface)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.appleBlue.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                        )
                        .foregroundStyle(Color.appleBlue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Teclado Numerico Integrado

    private var numericKeypad: some View {
        VStack(spacing: 10) {
            let keys = [
                ["1", "2", "3"],
                ["4", "5", "6"],
                ["7", "8", "9"],
                [".", "0", "backspace"]
            ]

            ForEach(keys, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            viewModel.handleKeyInput(key)
                        } label: {
                            Group {
                                if key == "backspace" {
                                    Image(systemName: "delete.left.fill")
                                        .font(.system(size: 18))
                                } else {
                                    Text(key)
                                        .font(.system(size: 22, weight: .medium, design: .rounded))
                                }
                            }
                            .foregroundStyle(Color.applePrimary)
                            .frame(maxWidth: .infinity, maxHeight: 48)
                            .background(Color.appleSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}
