import SwiftUI

/// Vista modal para crear una nueva categoría de transacción dinámica estilo Apple
struct CreateCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var categoryService = CategoryService.shared
    
    @State private var categoryName = ""
    @State private var selectedIcon = "bag.fill"
    @State private var selectedColorHex = "007AFF"
    @State private var isLoading = false
    
    // Curación de SF Symbols financieros e ilustrativos premium
    private let availableIcons = [
        "bag.fill", "cart.fill", "gift.fill", "heart.fill",
        "airplane", "tram.fill", "bolt.fill", "book.closed.fill",
        "pawprint.fill", "tv.fill", "creditcard.fill", "sparkles"
    ]
    
    // Paleta de colores iOS HSL perfectamente coordinados y limpios
    private let availableColors = [
        "FF3B30", // Rojo
        "FF9500", // Naranja
        "FFCC00", // Amarillo Oro
        "34C759", // Verde
        "007AFF", // Azul
        "5856D6", // Índigo
        "AF52DE", // Púrpura
        "FF2D55", // Rosado
        "A2845E", // Bronce / Café
        "8E8E93"  // Gris Neutro
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appleBackground.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Vista Previa de la Categoría en tiempo real
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppStyle.hex(selectedColorHex).opacity(0.12))
                                    .frame(width: 72, height: 72)
                                
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(AppStyle.hex(selectedColorHex))
                            }
                            
                            Text(categoryName.isEmpty ? "Nueva Categoría" : categoryName)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.applePrimary)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .appleCardStyle()
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        VStack(spacing: 20) {
                            // Nombre de la Categoría
                            VStack(alignment: .leading, spacing: 6) {
                                Text("NOMBRE DE CATEGORÍA")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.appleSecondary)
                                    .tracking(0.5)
                                    .padding(.leading, 4)
                                
                                TextField("Ej: Suscripciones, Mascotas, Regalos", text: $categoryName)
                                    .foregroundStyle(Color.applePrimary)
                                    .appleTextFieldStyle()
                            }
                            
                            // Grid de Iconos
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SELECCIONAR ICONO")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.appleSecondary)
                                    .tracking(0.5)
                                    .padding(.leading, 4)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                                    ForEach(availableIcons, id: \.self) { icon in
                                        let isSelected = selectedIcon == icon
                                        Button {
                                            selectedIcon = icon
                                            UISelectionFeedbackGenerator().selectionChanged()
                                        } label: {
                                            Image(systemName: icon)
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundStyle(isSelected ? Color.white : Color.applePrimary)
                                                .frame(width: 44, height: 44)
                                                .background(isSelected ? AppStyle.hex(selectedColorHex) : Color.appleBackground)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(isSelected ? Color.clear : Color.appleLightGray, lineWidth: 1)
                                                )
                                                .scaleEffect(isSelected ? 1.1 : 1.0)
                                                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
                                        }
                                    }
                                }
                            }
                            
                            // Selector de Colores
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SELECCIONAR COLOR")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.appleSecondary)
                                    .tracking(0.5)
                                    .padding(.leading, 4)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                                    ForEach(availableColors, id: \.self) { hex in
                                        let isSelected = selectedColorHex == hex
                                        Button {
                                            selectedColorHex = hex
                                            UISelectionFeedbackGenerator().selectionChanged()
                                        } label: {
                                            Circle()
                                                .fill(AppStyle.hex(hex))
                                                .frame(width: 36, height: 36)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                                                        .appleShadow()
                                                )
                                                .scaleEffect(isSelected ? 1.15 : 1.0)
                                                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isSelected)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .appleCardStyle()
                        .padding(.horizontal, 24)
                        
                        // Botón de guardar
                        Button {
                            Task {
                                isLoading = true
                                let success = await categoryService.createCategory(
                                    name: categoryName.isEmpty ? "Categoría Nueva" : categoryName,
                                    iconName: selectedIcon,
                                    hexColor: selectedColorHex
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
                                    Text("Crear Categoría")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .background(isLoading || categoryName.isEmpty ? AppStyle.hex(selectedColorHex).opacity(0.6) : AppStyle.hex(selectedColorHex))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .appleShadow()
                        }
                        .disabled(isLoading || categoryName.isEmpty)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
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
    CreateCategoryView()
}
