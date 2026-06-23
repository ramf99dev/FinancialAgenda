import SwiftUI

/// Vista modal para crear una nueva cuenta financiera estilo Apple
struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var accountService = AccountService.shared
    
    @State private var accountName = ""
    @State private var accountType = "checking"
    @State private var initialBalanceString = "0.00"
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appleBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Mensaje Informativo
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NUEVA CUENTA")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.appleSecondary)
                            .tracking(1.0)
                        
                        Text("Configura tu cuenta")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.applePrimary)
                        
                        Text("Ingresa los datos iniciales para comenzar a registrar operaciones.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appleSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        // Nombre de la Cuenta
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NOMBRE DE CUENTA")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.appleSecondary)
                                .tracking(0.5)
                                .padding(.leading, 4)
                            
                            TextField("Ej: Cuenta Corriente, Tarjeta Nómina", text: $accountName)
                                .foregroundStyle(Color.applePrimary)
                                .appleTextFieldStyle()
                        }
                        
                        // Tipo de Fondo / Cuenta (REDiseño Premium)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("TIPO DE FONDO / CUENTA")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.appleSecondary)
                                .tracking(0.5)
                                .padding(.leading, 4)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    let fundOptions = [
                                        ("checking", "Banco / Corriente", "Cuenta bancaria de uso diario", "building.columns.fill", Color.appleBlue),
                                        ("savings", "Ahorros", "Fondo reservado para metas", "leaf.fill", Color.appleGreen),
                                        ("credit", "Tarjeta de Crédito", "Líneas de crédito bancario", "creditcard.fill", Color.appleRed),
                                        ("cash", "Efectivo", "Dinero físico en billetera", "banknote.fill", Color.appleGreen),
                                        ("crypto", "Binance / Cripto", "Fondos criptográficos Binance", "bitcoinsign.circle.fill", Color.orange),
                                        ("wallet", "Billetera Digital", "PayPal, Pago Móvil, etc.", "wallet.pass.fill", Color.purple)
                                    ]
                                    
                                    ForEach(fundOptions, id: \.0) { id, title, description, icon, color in
                                        let isSelected = accountType == id
                                        Button {
                                            accountType = id
                                            UISelectionFeedbackGenerator().selectionChanged()
                                        } label: {
                                            VStack(alignment: .leading, spacing: 10) {
                                                HStack {
                                                    ZStack {
                                                        Circle()
                                                            .fill(color.opacity(0.12))
                                                            .frame(width: 32, height: 32)
                                                        
                                                        Image(systemName: icon)
                                                            .font(.system(size: 13, weight: .semibold))
                                                            .foregroundStyle(color)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    if isSelected {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .font(.system(size: 15))
                                                            .foregroundStyle(color)
                                                    }
                                                }
                                                
                                                Spacer()
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(title)
                                                        .font(.system(size: 13, weight: .bold))
                                                        .foregroundStyle(Color.applePrimary)
                                                    Text(description)
                                                        .font(.system(size: 10))
                                                        .foregroundStyle(Color.appleSecondary)
                                                        .lineLimit(2)
                                                        .multilineTextAlignment(.leading)
                                                }
                                            }
                                            .padding(12)
                                            .frame(width: 140, height: 125)
                                            .background(isSelected ? color.opacity(0.04) : Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(isSelected ? color : Color.appleLightGray, lineWidth: isSelected ? 2 : 1)
                                            )
                                            .appleShadow()
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 4)
                            }
                        }
                        
                        // Saldo Inicial
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SALDO INICIAL (USD)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.appleSecondary)
                                .tracking(0.5)
                                .padding(.leading, 4)
                            
                            HStack {
                                Text("$")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color.appleSecondary)
                                
                                TextField("0.00", text: $initialBalanceString)
                                    .keyboardType(.decimalPad)
                                    .foregroundStyle(Color.applePrimary)
                            }
                            .appleTextFieldStyle()
                        }
                    }
                    .padding(20)
                    .appleCardStyle()
                    .padding(.horizontal, 24)
                    
                    // Boton de Enviar
                    Button {
                        Task {
                            isLoading = true
                            let balance = Double(initialBalanceString) ?? 0.0
                            let success = await accountService.createAccount(
                                name: accountName.isEmpty ? "Cuenta Nueva" : accountName,
                                type: accountType,
                                initialBalance: balance
                            )
                            isLoading = false
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Crear Cuenta")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(isLoading || accountName.isEmpty ? Color.appleBlue.opacity(0.6) : Color.appleBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .appleShadow()
                    }
                    .disabled(isLoading || accountName.isEmpty)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .font(.system(size: 16))
                    .foregroundStyle(Color.appleBlue)
                }
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
