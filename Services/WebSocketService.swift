//
//  WebSocketService.swift
//  BlueTradingApp
//
//  Created by Ali Al-Khazali on 7/7/25.
//

import Foundation

class WebSocketService: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "ws://127.0.0.1:8002")! // ✅ WebSocket الجديد لبيانات EUR/USD
    var onSignalReceived: ((String, String) -> Void)?
    @Published var isConnected = false
    @Published var signal: String = "HOLD"
    @Published var price: String = "--"
    @Published var lastUpdated: Date = Date()
    @Published var priceHistory: [PricePoint] = []
    var onChartUpdate: (() -> Void)?  // ✅ هذا مهم لضمان استدعاء updateChartJSON
    func connect() {
        print("🔌 Connecting to \(url.absoluteString)...")
        let session = URLSession(configuration: .ephemeral)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        listen()
    }
    private func listen() {
        guard isConnected else {
            print("🔕 Stopped listening (not connected)")
            return
        }

        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("❌ WebSocket error: \(error.localizedDescription)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📩 Message received: \(text)")
                    self.handleChartData(text)
                default:
                    print("⚠️ Unsupported message format")
                }
            }

            // 👇 فقط استمع مرة أخرى إذا ما زلنا متصلين
            if self.isConnected {
                self.listen()
            }
        }
    }
    private func handleChartData(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }

        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // تنسيق مطابق للبيانات المستلمة
        decoder.dateDecodingStrategy = .formatted(formatter)

        do {
            let decodedPoints = try decoder.decode([PricePoint].self, from: data)
            DispatchQueue.main.async {
                self.priceHistory = decodedPoints
                self.onChartUpdate?() // نداء لتحديث JSON

            }
        } catch {
            print("❗️ Failed to decode chart data: \(error.localizedDescription)")
        }
    }
    
    func disconnect() {
        isConnected = false
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    struct SignalMessage: Codable {
        let signal: String
        let price: String
    }
}
