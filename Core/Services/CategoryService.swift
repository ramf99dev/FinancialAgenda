import Foundation
import Combine
import Supabase

/// Servicio unificado para gestionar categorías de transacciones dinámicas conectadas a Supabase
@MainActor
public final class CategoryService: ObservableObject {
    @Published public var categories: [Category] = []
    @Published public var isLoading = false
    
    public static let shared = CategoryService()
    
    private let client = AppSupabaseClient.shared.client
    private var realtimeChannel: RealtimeChannelV2? = nil
    
    private init() {
        // Inicializar con la lista estática por defecto en caso de desconexión
        self.categories = Category.all
    }
    
    /// Obtiene las categorías visibles para el usuario (del sistema o personalizadas)
    public func fetchCategories() async {
        isLoading = true
        do {
            // Descarga todas las categorías a las que el RLS del usuario tiene acceso
            let response: [Category] = try await client
                .from("categories")
                .select()
                .execute()
                .value
            
            // Ordenar las categorías: las del sistema primero, seguidas por las personalizadas alfabéticamente
            self.categories = response.sorted { (cat1, cat2) -> Bool in
                if cat1.userId == nil && cat2.userId != nil {
                    return true
                }
                if cat1.userId != nil && cat2.userId == nil {
                    return false
                }
                return cat1.name.localizedCompare(cat2.name) == .orderedAscending
            }
            self.isLoading = false
            
            // Suscribirse al canal en tiempo real en segundo plano sin bloquear
            Task {
                await subscribeToRealtimeCategories()
            }
        } catch {
            self.isLoading = false
            print("Error al descargar categorias de Supabase: \(error.localizedDescription)")
            // Fallback en caso de error
            if self.categories.isEmpty {
                self.categories = Category.all
            }
        }
    }
    
    /// Inserta una nueva categoría personalizada para el usuario logueado en Supabase
    public func createCategory(name: String, iconName: String, hexColor: String) async -> Bool {
        guard let session = try? await client.auth.session else { return false }
        let userId = session.user.id
        
        let newCategory = Category(
            id: UUID().uuidString.lowercased(),
            userId: userId,
            name: name,
            iconName: iconName,
            hexColor: hexColor
        )
        
        do {
            try await client
                .from("categories")
                .insert(newCategory)
                .execute()
            
            // Refrescar localmente de inmediato
            await fetchCategories()
            return true
        } catch {
            print("Error al crear categoria en Supabase: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Suscribe la aplicación a actualizaciones en tiempo real de la tabla categories
    public func subscribeToRealtimeCategories() async {
        guard realtimeChannel == nil else { return }
        
        let channel = client.realtimeV2.channel("public-categories-changes")
        
        _ = channel.onPostgresChange(
            AnyAction.self,
            schema: "public",
            table: "categories"
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchCategories()
            }
        }
        
        self.realtimeChannel = channel
        do {
            try await channel.subscribe()
        } catch {
            print("Error suscribiendo: \(error)")
        }
    }
    
    /// Cancela la suscripción en tiempo real al cerrar sesión
    public func unsubscribe() async {
        if let channel = realtimeChannel {
            await client.realtimeV2.removeChannel(channel)
            self.realtimeChannel = nil
        }
        self.categories = Category.all
    }
}
