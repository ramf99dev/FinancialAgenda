import Foundation
import SwiftUI
import Combine

/// Servicio de Tasas de Cambio de Referencia (BCV y Binance P2P) en tiempo real
public final class ExchangeRateService: ObservableObject {
    public static let shared = ExchangeRateService()
    
    @Published public var bcvRate: Double = 36.50
    @Published public var binanceRate: Double = 38.40 // Compatibilidad retrospectiva (compra)
    @Published public var binanceBuyRate: Double = 38.40
    @Published public var binanceSellRate: Double = 38.60
    @Published public var bybitBuyRate: Double = 38.30
    @Published public var bybitSellRate: Double = 38.50
    @Published public var lastUpdated: Date? = nil
    @Published public var isFetching: Bool = false
    @Published public var errorMessage: String? = nil
    
    private init() {
        self.bcvRate = 36.50
        self.binanceRate = 36.50 * 1.052
        self.binanceBuyRate = 36.50 * 1.052
        self.binanceSellRate = 36.50 * 1.055
        self.bybitBuyRate = 36.50 * 1.050
        self.bybitSellRate = 36.50 * 1.053
    }
    
    /// Descarga las tasas reales consolidadas desde el nuevo Cloudflare Worker
    public func fetchRates() async {
        guard !isFetching else { return }
        
        await MainActor.run {
            self.isFetching = true
            self.errorMessage = nil
        }
        
        guard let url = URL(string: "https://tasa-usdt-scraper.molinafloresrandy99.workers.dev/") else {
            await MainActor.run {
                self.isFetching = false
                self.errorMessage = "URL inválida"
            }
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            struct WorkerResponse: Decodable {
                let ok: Bool
                let bcv: Double
                let binance: P2PRates
                let bybit: P2PRates
                
                struct P2PRates: Decodable {
                    let buy: Double
                    let sell: Double
                }
            }
            
            let result = try JSONDecoder().decode(WorkerResponse.self, from: data)
            
            if result.ok {
                await MainActor.run {
                    self.bcvRate = result.bcv
                    self.binanceBuyRate = result.binance.buy
                    self.binanceSellRate = result.binance.sell
                    self.binanceRate = result.binance.buy // Para retrocompatibilidad
                    self.bybitBuyRate = result.bybit.buy
                    self.bybitSellRate = result.bybit.sell
                    self.lastUpdated = Date()
                    self.isFetching = false
                }
            } else {
                throw NSError(domain: "USDTWorker", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error en el Worker"])
            }
            
        } catch {
            await MainActor.run {
                self.isFetching = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
