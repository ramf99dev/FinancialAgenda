// Vista detallada del resumen de cuentas financieras del usuario
// Presenta el balance consolidado, lista de cuentas activas con
// acciones de eliminacion y utilidades centralizadas.

import SwiftUI

/// Vista de resumen de cuentas y saldo consolidado con estetica nativa iOS 26
struct AccountsSummaryView: View {
    @ObservedObject private var accountService = AccountService.shared
    @State private var showCreateAccount = false
    @State private var accountToDelete: Account? = nil

    /// Saldo consolidado de todas las cuentas
    private var totalBalance: Double {
        accountService.accounts.reduce(0) { $0 + $1.balance }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Tarjeta de Balance Consolidado
                    balanceCard

                    // Lista de Cuentas Activas
                    accountsList
                }
                .padding(.bottom, 32)
            }
            .background(Color.appleBackground)
            .navigationTitle("Mis Cuentas")
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateAccount = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.appleBlue)
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateAccount) {
            CreateAccountView()
        }
        .task {
            await accountService.fetchAccounts()
        }
        .alert("Eliminar Cuenta", isPresented: .init(
            get: { accountToDelete != nil },
            set: { if !$0 { accountToDelete = nil } }
        )) {
            Button("Cancelar", role: .cancel) {
                accountToDelete = nil
            }
            Button("Eliminar", role: .destructive) {
                if let account = accountToDelete {
                    Task {
                        await accountService.deleteAccount(account.id)
                    }
                }
            }
        } message: {
            if let account = accountToDelete {
                Text("Se eliminara la cuenta \"\(account.name)\" y todas sus transacciones asociadas. Esta accion no se puede deshacer.")
            }
        }
    }

    // MARK: - Tarjeta de Balance Consolidado

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Balance Total Consolidado")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.appleSecondary)

            Text(CurrencyFormatter.format(totalBalance))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Color.applePrimary)

            HStack(spacing: 4) {
                Image(systemName: totalBalance >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(totalBalance >= 0 ? Color.appleGreen : Color.appleRed)
                Text("\(accountService.accounts.count) cuenta\(accountService.accounts.count == 1 ? "" : "s") activa\(accountService.accounts.count == 1 ? "" : "s")")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.appleSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .appleCardStyle()
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    // MARK: - Lista de Cuentas

    private var accountsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CUENTAS ACTIVAS")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.appleSecondary)
                .tracking(1.0)
                .padding(.leading, 28)

            if accountService.accounts.isEmpty {
                // Estado vacio guiado
                VStack(spacing: 12) {
                    Image(systemName: "creditcard.and.123")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.appleSecondary.opacity(0.5))
                    Text("Aun no tienes cuentas registradas.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appleSecondary)

                    Button("Crear Primera Cuenta") {
                        showCreateAccount = true
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appleBlue)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .appleCardStyle()
                .padding(.horizontal, 20)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(accountService.accounts.enumerated()), id: \.element.id) { index, account in
                        AccountDetailRow(
                            title: account.name,
                            subtitle: account.accountNumber,
                            balance: account.balance,
                            icon: AccountTypeMapper.icon(for: account.type),
                            iconColor: AccountTypeMapper.color(for: account.type)
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                accountToDelete = account
                            } label: {
                                Label("Eliminar", systemImage: "trash.fill")
                            }
                        }

                        if index < accountService.accounts.count - 1 {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
                .appleCardStyle()
                .padding(.horizontal, 20)
            }
        }
    }
}

/// Fila individual de detalle de cuenta bancaria
struct AccountDetailRow: View {
    let title: String
    let subtitle: String
    let balance: Double
    let icon: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.applePrimary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appleSecondary)
            }

            Spacer()

            Text(CurrencyFormatter.format(balance))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(balance >= 0 ? Color.applePrimary : Color.appleRed)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
    }
}
