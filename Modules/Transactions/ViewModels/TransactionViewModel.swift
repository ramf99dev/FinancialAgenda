// ViewModel para el registro de transacciones
// Encapsula la logica de validacion, el teclado numerico personalizado
// y la comunicacion con TransactionService.

import SwiftUI
import Combine

/// ViewModel que gestiona el estado y la logica de registro de una nueva transaccion
@MainActor
public final class TransactionViewModel: ObservableObject {

    // MARK: - Servicios

    private let txService = TransactionService.shared
    private let accountService = AccountService.shared
    @Published public var categoryService = CategoryService.shared

    // MARK: - Estado del Formulario

    /// Cadena de texto del monto ingresado por el teclado numerico
    @Published public var amountString = "0"

    /// Tipo de transaccion seleccionado
    @Published public var selectedType: TransactionType = .expense

    /// Identificador de la categoria seleccionada
    @Published public var selectedCategoryId = "food"

    /// Identificador de la cuenta bancaria seleccionada
    @Published public var selectedAccountId: UUID? = nil

    /// Nota descriptiva opcional de la transaccion
    @Published public var note = ""

    /// Fecha de la transaccion (por defecto: hoy, permite registrar dias anteriores)
    @Published public var transactionDate = Date()

    // MARK: - Estado de la Vista

    /// Indica si la transaccion se esta guardando
    @Published public var isSaving = false

    /// Indica si debe mostrarse la alerta de error
    @Published public var showErrorAlert = false

    /// Mensaje de error para mostrar en la alerta
    @Published public var errorMessage = ""

    /// Indica si debe mostrarse la hoja de creacion de categoria
    @Published public var showCreateCategorySheet = false

    // MARK: - Inicializacion

    /// Configura el ViewModel con el tipo preseleccionado y la primera cuenta disponible
    public func configure(preselectedType: TransactionType) {
        selectedType = preselectedType
        selectedAccountId = accountService.accounts.first?.id
        selectedCategoryId = preselectedType == .income ? "salary" : "food"
    }

    // MARK: - Validacion

    /// Monto numerico actual del formulario
    public var currentAmount: Double {
        Double(amountString) ?? 0
    }

    /// Indica si el formulario es valido para enviar
    public var isFormValid: Bool {
        currentAmount > 0 && selectedAccountId != nil
    }

    /// Saldo proyectado de la cuenta tras realizar la operacion
    public var projectedBalance: Double? {
        guard let accountId = selectedAccountId,
              let account = accountService.accounts.first(where: { $0.id == accountId }) else {
            return nil
        }
        if selectedType == .income {
            return account.balance + currentAmount
        } else {
            return account.balance - currentAmount
        }
    }

    /// Cuentas disponibles del usuario
    public var accounts: [Account] {
        accountService.accounts
    }

    // MARK: - Teclado Numerico

    /// Procesa una tecla del teclado numerico personalizado
    public func handleKeyInput(_ key: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        switch key {
        case "backspace":
            if !amountString.isEmpty {
                amountString.removeLast()
                if amountString.isEmpty { amountString = "0" }
            }
        case ".":
            if !amountString.contains(".") {
                amountString += "."
            }
        default:
            if amountString == "0" {
                amountString = key
            } else {
                // Limitar a 2 decimales si ya tiene punto
                if let dotIndex = amountString.firstIndex(of: ".") {
                    let decimals = amountString.distance(from: dotIndex, to: amountString.endIndex) - 1
                    if decimals >= 2 { return }
                }
                amountString += key
            }
        }
    }

    // MARK: - Guardar Transaccion

    /// Guarda la transaccion en Supabase y actualiza el saldo de la cuenta
    public func saveTransaction() async -> Bool {
        guard isFormValid, let accountId = selectedAccountId else { return false }

        isSaving = true
        let errorMsg = await txService.saveTransaction(
            amount: currentAmount,
            type: selectedType,
            categoryId: selectedCategoryId,
            note: note.isEmpty ? nil : note,
            accountId: accountId
        )

        isSaving = false

        if let errorMsg = errorMsg {
            self.errorMessage = errorMsg
            self.showErrorAlert = true
            return false
        }

        return true
    }

    // MARK: - Cambio de Tipo

    /// Actualiza la categoria por defecto al cambiar el tipo de transaccion
    public func onTypeChanged(_ newType: TransactionType) {
        selectedCategoryId = newType == .income ? "salary" : "food"
    }

    // MARK: - Carga Inicial

    /// Carga las categorias disponibles desde Supabase
    public func loadCategories() async {
        await categoryService.fetchCategories()
        if selectedAccountId == nil {
            selectedAccountId = accountService.accounts.first?.id
        }
    }
}
