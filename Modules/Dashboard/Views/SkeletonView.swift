import SwiftUI

/// Modificador de shimmer para animar esqueletos de carga de forma premium
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .clear,
                                    Color.white.opacity(0.4),
                                    .clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(width: geo.size.width * 2)
                            .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                        )
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    self.phase = 1
                }
                scheduleAnimationReset()
            }
    }
    
    private func scheduleAnimationReset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            self.phase = 0
            withAnimation(Animation.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                self.phase = 1
            }
            self.scheduleAnimationReset()
        }
    }
}

extension View {
    /// Aplica un efecto de brillo (shimmer) animado para estados de carga
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

/// Elemento básico de esqueleto de carga con bordes redondeados y shimmer
struct SkeletonBlock: View {
    var width: CGFloat? = nil
    var height: CGFloat
    var cornerRadius: CGFloat = 8
    var color: Color = Color.appleLightGray.opacity(0.6)

    init(width: CGFloat? = nil, height: CGFloat, cornerRadius: CGFloat = 8, color: Color = Color.appleLightGray.opacity(0.6)) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.color = color
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(color)
            .frame(width: width, height: height)
            .shimmer()
    }
}

/// Esqueleto de carga premium para la tarjeta de Balance Total
struct BalanceCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SkeletonBlock(width: 80, height: 13, cornerRadius: 4, color: Color.white.opacity(0.15))
                Spacer()
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 32, height: 32)
                    .shimmer()
            }
            
            SkeletonBlock(width: 180, height: 34, cornerRadius: 6, color: Color.white.opacity(0.2))
            
            // Subtexto / Conversión opcional
            SkeletonBlock(width: 120, height: 13, cornerRadius: 4, color: Color.white.opacity(0.15))
            
            // Indicador de tendencia
            SkeletonBlock(width: 100, height: 22, cornerRadius: 11, color: Color.white.opacity(0.15))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 25/255, green: 35/255, blue: 60/255),
                            Color(red: 35/255, green: 48/255, blue: 78/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}

/// Esqueleto de carga para el widget de presupuesto mensual
struct BudgetWidgetSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SkeletonBlock(width: 100, height: 13, cornerRadius: 4)
                Spacer()
                SkeletonBlock(width: 60, height: 13, cornerRadius: 4)
            }
            
            // Barra de progreso
            SkeletonBlock(height: 8, cornerRadius: 4)
            
            HStack {
                SkeletonBlock(width: 140, height: 11, cornerRadius: 3)
                Spacer()
                SkeletonBlock(width: 80, height: 11, cornerRadius: 3)
            }
        }
        .padding(16)
        .appleCardStyle()
        .padding(.horizontal, 20)
    }
}

/// Fila esqueleto individual para simular una cuenta o transacción en listas
struct ListRowSkeleton: View {
    var hasIconCircle: Bool = true
    
    init(hasIconCircle: Bool = true) {
        self.hasIconCircle = hasIconCircle
    }
    
    var body: some View {
        HStack(spacing: 14) {
            if hasIconCircle {
                Circle()
                    .fill(Color.appleLightGray.opacity(0.6))
                    .frame(width: 42, height: 42)
                    .shimmer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                SkeletonBlock(width: 120, height: 14, cornerRadius: 4)
                SkeletonBlock(width: 70, height: 10, cornerRadius: 3)
            }
            
            Spacer()
            
            SkeletonBlock(width: 80, height: 16, cornerRadius: 4)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

/// Vista esqueleto completa para simular el dashboard en carga
struct DashboardSkeletonView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Tarjeta de Balance
                BalanceCardSkeleton()
                    .padding(.top, 4)
                
                // Widget de presupuesto
                BudgetWidgetSkeleton()
                
                // Widgets en fila
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 10) {
                        SkeletonBlock(width: 40, height: 40, cornerRadius: 10)
                        SkeletonBlock(width: 70, height: 12, cornerRadius: 3)
                    }
                    .frame(maxWidth: .infinity, minHeight: 110)
                    .padding(12)
                    .appleCardStyle()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        SkeletonBlock(width: 40, height: 40, cornerRadius: 10)
                        SkeletonBlock(width: 70, height: 12, cornerRadius: 3)
                    }
                    .frame(maxWidth: .infinity, minHeight: 110)
                    .padding(12)
                    .appleCardStyle()
                }
                .padding(.horizontal, 20)
                
                // Sección de cuentas
                VStack(alignment: .leading, spacing: 12) {
                    SkeletonBlock(width: 100, height: 12, cornerRadius: 3)
                        .padding(.leading, 8)
                    
                    VStack(spacing: 0) {
                        ListRowSkeleton(hasIconCircle: true)
                        Divider().padding(.leading, 64)
                        ListRowSkeleton(hasIconCircle: true)
                    }
                    .appleCardStyle()
                }
                .padding(.horizontal, 20)
                
                // Sección de transacciones recientes
                VStack(alignment: .leading, spacing: 12) {
                    SkeletonBlock(width: 120, height: 12, cornerRadius: 3)
                        .padding(.leading, 8)
                    
                    VStack(spacing: 0) {
                        ListRowSkeleton(hasIconCircle: true)
                        Divider().padding(.leading, 64)
                        ListRowSkeleton(hasIconCircle: true)
                        Divider().padding(.leading, 64)
                        ListRowSkeleton(hasIconCircle: true)
                    }
                    .appleCardStyle()
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 32)
        }
        .background(Color.appleBackground)
        .disabled(true) // Deshabilitar interacciones durante la carga
    }
}

#Preview {
    DashboardSkeletonView()
}
