// Vista principal del Dashboard - Resumen financiero
// Presenta el balance consolidado, salud financiera, cuentas, presupuesto
// y las ultimas transacciones del usuario en un diseno minimalista nativo iOS 26.

import SwiftUI

/// Vista principal de resumen financiero con sincronizacion en tiempo real
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    DashboardSkeletonView()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            
                            // -- Tarjeta de Balance Total Consolidado --
                            balanceCard
                            
                            // -- Widget de Presupuesto Mensual --
                            BudgetWidgetView(
                                totalBudget: viewModel.budgetService.totalBudget(),
                                totalSpent: viewModel.totalExpenses
                            )
                            .padding(.horizontal, 20)
                            
                            // -- Fila de Widgets: Calculadora + Salud Financiera --
                            widgetRow
                            
                            // -- Flujo de Caja Real --
                            cashFlowCard
                            
                            // -- Seccion: Mis Cuentas --
                            accountsSection
                            
                            // -- Entradas Rapidas --
                            quickActionsSection
                            
                            // -- Historial de Movimientos Recientes --
                            recentTransactionsSection
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
            .background(Color.appleBackground)
            .navigationTitle("Resumen")
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddTransactionView(preselectedType: viewModel.initialTransactionType)
        }
        .sheet(isPresented: $viewModel.showCreateAccountSheet) {
            CreateAccountView()
        }
        .sheet(isPresented: $viewModel.showCalculatorSheet) {
            ExchangeCalculatorView()
        }
        .task {
            await viewModel.loadDashboardData()
        }
    }

    // MARK: - Tarjeta de Balance

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Balance Total")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.7))

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 32, height: 32)

                    Image(systemName: "wallet.bifold.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
            }

            Text(viewModel.formatBalance(viewModel.totalBalance))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())

            // Conversion a VES (configurable por el usuario)
            if viewModel.showVesConversion {
                HStack(spacing: 4) {
                    Text(viewModel.formatVesBalance(viewModel.totalBalance * viewModel.rateService.bcvRate))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appleGreen)

                    Text("BCV Bs. \(String(format: "%.2f", viewModel.rateService.bcvRate))")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
            }

            // Indicador de tendencia
            HStack(spacing: 6) {
                Image(systemName: viewModel.netFlow >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(viewModel.netFlow >= 0 ? Color.appleGreen : Color.appleRed)

                Text(viewModel.netFlow >= 0 ? "Flujo positivo" : "Flujo negativo")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(viewModel.netFlow >= 0 ? Color.appleGreen : Color.appleRed)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 20/255, green: 28/255, blue: 50/255),
                            Color(red: 30/255, green: 40/255, blue: 65/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    // MARK: - Fila de Widgets

    private var widgetRow: some View {
        HStack(spacing: 12) {
            // Widget: Calculadora de Tasas
            Button {
                viewModel.showCalculatorSheet = true
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                VStack(spacing: 10) {
                    ZStack {
                        // Cuerpo de la calculadora (vertical gris claro estilo macOS/iOS clásico)
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(red: 215/255, green: 215/255, blue: 217/255))
                            .frame(width: 38, height: 52)
                            .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 1.5)
                        
                        VStack(spacing: 4) {
                            // Pantalla (gris oscuro)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(red: 60/255, green: 60/255, blue: 60/255))
                                .frame(width: 30, height: 13)
                            
                            // Botones grid 3x3 (6 gris oscuro, 3 naranja)
                            VStack(spacing: 3) {
                                HStack(spacing: 3) {
                                    Circle().fill(Color(red: 65/255, green: 65/255, blue: 65/255)).frame(width: 7, height: 7)
                                    Circle().fill(Color(red: 65/255, green: 65/255, blue: 65/255)).frame(width: 7, height: 7)
                                    Circle().fill(Color.orange).frame(width: 7, height: 7)
                                }
                                HStack(spacing: 3) {
                                    Circle().fill(Color(red: 65/255, green: 65/255, blue: 65/255)).frame(width: 7, height: 7)
                                    Circle().fill(Color(red: 65/255, green: 65/255, blue: 65/255)).frame(width: 7, height: 7)
                                    Circle().fill(Color.orange).frame(width: 7, height: 7)
                                }
                                HStack(spacing: 3) {
                                    Circle().fill(Color(red: 65/255, green: 65/255, blue: 65/255)).frame(width: 7, height: 7)
                                    Circle().fill(Color(red: 65/255, green: 65/255, blue: 65/255)).frame(width: 7, height: 7)
                                    Circle().fill(Color.orange).frame(width: 7, height: 7)
                                }
                            }
                        }
                    }

                    VStack(spacing: 2) {
                        Text("Calculadora")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.applePrimary)

                        Text("Tasas de Cambio")
                            .font(.system(size: 9))
                            .foregroundStyle(Color.appleSecondary)
                    }
                }
                .frame(width: 100, height: 110)
                .appleCardStyle()
            }
            .buttonStyle(.plain)

            // Widget: Salud Financiera
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Salud Financiera")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.applePrimary)

                        Text(viewModel.financialHealthStatus)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(viewModel.financialHealthColor)
                    }

                    Spacer()

                    // Medidor circular de salud
                    ZStack {
                        Circle()
                            .stroke(Color.appleLightGray, lineWidth: 3.5)
                            .frame(width: 38, height: 38)

                        Circle()
                            .trim(from: 0, to: CGFloat(viewModel.financialHealthScore / 100.0))
                            .stroke(
                                viewModel.financialHealthColor,
                                style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                            )
                            .frame(width: 38, height: 38)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(), value: viewModel.financialHealthScore)

                        Text("\(Int(viewModel.financialHealthScore))")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.applePrimary)
                    }
                }

                Text(viewModel.financialHealthRecommendation)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.appleSecondary)
                    .lineLimit(2)
                    .frame(height: 28, alignment: .topLeading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 110)
            .appleCardStyle()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Flujo de Caja

    private var cashFlowCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.teal)
                }

                Text("Flujo de Caja")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.applePrimary)

                Spacer()

                Text(viewModel.formatBalance(viewModel.netFlow))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.netFlow >= 0 ? Color.appleGreen : Color.appleRed)
            }

            Divider()

            VStack(spacing: 8) {
                HStack {
                    Text("Ingresos")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appleSecondary)
                    Spacer()
                    Text(viewModel.formatBalance(viewModel.totalIncomes))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appleGreen)
                }

                HStack {
                    Text("Egresos")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appleSecondary)
                    Spacer()
                    Text(viewModel.formatBalance(viewModel.totalExpenses))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appleRed)
                }
            }
        }
        .padding(18)
        .appleCardStyle()
        .padding(.horizontal, 20)
    }

    // MARK: - Seccion de Cuentas

    private var accountsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mis Cuentas")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.applePrimary)

                Spacer()

                Button {
                    viewModel.showCreateAccountSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.appleBlue)
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if viewModel.accountService.accounts.isEmpty {
                        // Estado vacio guiado
                        Button {
                            viewModel.showCreateAccountSheet = true
                        } label: {
                            VStack(spacing: 12) {
                                Image(systemName: "plus.circle.dashed")
                                    .font(.system(size: 26))
                                    .foregroundStyle(Color.appleBlue)
                                Text("Crear Cuenta")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.appleBlue)
                            }
                            .frame(width: 140, height: 120)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.appleBlue.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                            )
                        }
                    } else {
                        ForEach(viewModel.accountService.accounts) { account in
                            BalanceCardView(
                                cardName: account.name,
                                balance: account.balance,
                                currencyCode: account.currency,
                                iconName: AccountTypeMapper.icon(for: account.type),
                                iconColor: AccountTypeMapper.color(for: account.type)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Entradas Rapidas

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Entradas Rapidas")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.applePrimary)
                .padding(.horizontal, 20)

            HStack(spacing: 12) {
                // Registrar Gasto
                Button {
                    if viewModel.accountService.accounts.isEmpty {
                        viewModel.showCreateAccountSheet = true
                    } else {
                        viewModel.initialTransactionType = .expense
                        viewModel.showAddSheet = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 18))
                        Text("Gasto")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appleBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .appleShadow()
                }

                // Registrar Ingreso
                Button {
                    if viewModel.accountService.accounts.isEmpty {
                        viewModel.showCreateAccountSheet = true
                    } else {
                        viewModel.initialTransactionType = .income
                        viewModel.showAddSheet = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text("Ingreso")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appleGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .appleShadow()
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Transacciones Recientes

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Movimientos Recientes")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.applePrimary)
                .padding(.horizontal, 20)

            if viewModel.txService.transactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.up.slash")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.appleSecondary.opacity(0.6))
                    Text("Sin movimientos registrados.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appleSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .appleCardStyle()
                .padding(.horizontal, 20)
            } else {
                VStack(spacing: 0) {
                    let recentTxs = viewModel.txService.transactions.prefix(5)
                    ForEach(Array(recentTxs.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRowView(transaction: transaction)

                        if index < recentTxs.count - 1 {
                            Divider()
                                .padding(.leading, 76)
                        }
                    }
                }
                .appleCardStyle()
                .padding(.horizontal, 20)
            }
        }
    }
}
