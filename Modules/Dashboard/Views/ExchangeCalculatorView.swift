// Calculadora de tasas de cambio simplificada
// Provee conversion bidireccional USD/VES con tasas BCV y Binance P2P,
// comparador de plataformas y analisis de brecha cambiaria.
// Version minimalista con la misma funcionalidad.

import SwiftUI

/// Vista modal de calculadora de conversiones de divisas en tiempo real
struct ExchangeCalculatorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var rateService = ExchangeRateService.shared

    @State private var usdAmountString: String = "1"
    @State private var vesAmountString: String = ""
    @State private var selectedRateType: RateType = .bcv
    @State private var selectedTab: CalculatorTab = .converter
    @FocusState private var activeField: Field?

    enum Field { case usd, ves }
    enum RateType { case bcv, binance }
    enum CalculatorTab { case converter, comparator }

    // Tasa activa segun la seleccion del usuario
    private var activeRate: Double {
        selectedRateType == .bcv ? rateService.bcvRate : rateService.binanceRate
    }

    // Porcentaje de brecha entre tasa oficial y paralela
    private var gapPercentage: Double {
        guard rateService.bcvRate > 0 else { return 0 }
        return ((rateService.binanceBuyRate - rateService.bcvRate) / rateService.bcvRate) * 100.0
    }

    // Estado semantico de la brecha
    private var gapInfo: (label: String, message: String, color: Color) {
        let gap = gapPercentage
        if gap < 10 { return ("Minima", "Brecha minima. Ambas tasas son equivalentes.", .appleGreen) }
        if gap < 25 { return ("Baja", "Brecha tipica del mercado actual.", .appleGreen) }
        if gap < 60 { return ("Moderada", "Evalua tus opciones antes de operar.", .orange) }
        return ("Alta", "Prioriza operaciones a tasa oficial.", .appleRed)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Bloque: Tasas de Referencia
                rateCards

                // Selector de Vista
                Picker("Vista", selection: $selectedTab) {
                    Text("Convertidor").tag(CalculatorTab.converter)
                    Text("Brecha").tag(CalculatorTab.comparator)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .onChange(of: selectedTab) { _ in activeField = nil }

                // Contenido activo
                ScrollView(.vertical, showsIndicators: false) {
                    if selectedTab == .converter {
                        converterSection
                    } else {
                        gapSection
                    }
                }
            }
            .background(Color.appleBackground)
            .navigationTitle("Calculadora de Tasas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(Color.appleSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if rateService.isFetching {
                        ProgressView().tint(Color.appleBlue)
                    } else {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            Task {
                                await rateService.fetchRates()
                                triggerCalculation()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(Color.appleBlue)
                        }
                    }
                }
            }
        }
        .onAppear {
            triggerCalculation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { activeField = .usd }
        }
    }

    // MARK: - Tarjetas de Tasas de Referencia

    private var rateCards: some View {
        HStack(spacing: 10) {
            rateCard(
                title: "Tasa BCV",
                icon: "building.columns.fill",
                iconColor: .appleBlue,
                value: rateService.bcvRate,
                isSelected: selectedRateType == .bcv
            ) {
                selectedRateType = .bcv
                triggerCalculation()
            }

            rateCard(
                title: "Tasa USDT",
                icon: "bitcoinsign.circle.fill",
                iconColor: .orange,
                value: rateService.binanceBuyRate,
                isSelected: selectedRateType == .binance
            ) {
                selectedRateType = .binance
                triggerCalculation()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func rateCard(title: String, icon: String, iconColor: Color, value: Double, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            action()
        }) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                        .foregroundStyle(iconColor)
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.appleSecondary)
                }

                Text("Bs. \(String(format: "%.2f", value))")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.applePrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .appleCardStyle()
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.appleBlue : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Convertidor

    private var converterSection: some View {
        VStack(spacing: 14) {
            // Campo USD
            VStack(alignment: .leading, spacing: 4) {
                Text("Importe en Dolares")
                    .font(.caption)
                    .foregroundStyle(Color.appleSecondary)

                HStack {
                    TextField("$0", text: $usdAmountString)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(activeField == .usd ? Color.appleBlue : Color.applePrimary)
                        .keyboardType(.decimalPad)
                        .focused($activeField, equals: .usd)
                        .onChange(of: usdAmountString) { _ in
                            if activeField == .usd { triggerCalculation() }
                        }
                    Spacer()
                    Text("USD")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.appleSecondary)
                }
            }
            .padding(14)
            .appleCardStyle()

            Image(systemName: activeField == .usd ? "arrow.down" : "arrow.up")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.appleBlue)

            // Campo VES
            VStack(alignment: .leading, spacing: 4) {
                Text("Importe en Bolivares")
                    .font(.caption)
                    .foregroundStyle(Color.appleSecondary)

                HStack {
                    TextField("Bs. 0", text: $vesAmountString)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(activeField == .ves ? Color.appleBlue : Color.applePrimary)
                        .keyboardType(.decimalPad)
                        .focused($activeField, equals: .ves)
                        .onChange(of: vesAmountString) { _ in
                            if activeField == .ves { triggerCalculation() }
                        }
                    Spacer()
                    Text("VES")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.appleSecondary)
                }
            }
            .padding(14)
            .appleCardStyle()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Seccion de Brecha

    private var gapSection: some View {
        VStack(spacing: 16) {
            // Indicador principal de brecha
            VStack(spacing: 8) {
                Text("\(String(format: "%.1f", gapPercentage))%")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(gapInfo.color)

                Text("Brecha BCV vs USDT")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appleSecondary)

                // Barra de brecha visual
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(LinearGradient(
                                colors: [.appleGreen, .orange, .appleRed],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(height: 6)

                        let percent = min(max(gapPercentage, 0) / 200.0, 1.0)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                            .shadow(color: .black.opacity(0.2), radius: 2)
                            .offset(x: CGFloat(percent) * (geo.size.width - 12))
                    }
                }
                .frame(height: 12)

                // Info banner
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(gapInfo.color)
                    Text(gapInfo.message)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(gapInfo.color)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(gapInfo.color.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(16)
            .appleCardStyle()

            // Tabla comparativa compacta
            VStack(alignment: .leading, spacing: 8) {
                Text("COMPARAR TASAS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.appleSecondary)
                    .tracking(1.0)

                VStack(spacing: 0) {
                    comparisonRow(name: "BCV Oficial", icon: "building.columns.fill", color: .appleBlue,
                                  buy: rateService.bcvRate, sell: rateService.bcvRate)
                    Divider()
                    comparisonRow(name: "Binance P2P", icon: "bitcoinsign.circle.fill", color: .orange,
                                  buy: rateService.binanceBuyRate, sell: rateService.binanceSellRate)
                    Divider()
                    comparisonRow(name: "Bybit P2P", icon: "dollarsign.circle.fill", color: .purple,
                                  buy: rateService.bybitBuyRate, sell: rateService.bybitSellRate)
                }
                .appleCardStyle()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func comparisonRow(name: String, icon: String, color: Color, buy: Double, sell: Double) -> some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(color)
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.applePrimary)
            }
            .frame(width: 100, alignment: .leading)

            Spacer()

            VStack(spacing: 1) {
                Text("Compra")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color.appleSecondary)
                Text(String(format: "%.2f", buy))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appleGreen)
            }
            .frame(width: 60)

            VStack(spacing: 1) {
                Text("Venta")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Color.appleSecondary)
                Text(String(format: "%.2f", sell))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appleRed)
            }
            .frame(width: 60)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
    }

    // MARK: - Calculo

    private func triggerCalculation() {
        if activeField == .usd || activeField == nil {
            guard let val = Double(usdAmountString.replacingOccurrences(of: ",", with: ".")) else {
                vesAmountString = ""
                return
            }
            vesAmountString = String(format: "%.2f", val * activeRate)
        } else if activeField == .ves {
            guard let val = Double(vesAmountString.replacingOccurrences(of: ",", with: ".")),
                  activeRate > 0 else {
                usdAmountString = ""
                return
            }
            usdAmountString = String(format: "%.2f", val / activeRate)
        }
    }
}
