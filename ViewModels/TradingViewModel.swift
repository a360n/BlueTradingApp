//
//  TradingViewModel.swift
//  BlueTradingApp
//
//  Created by Ali Al-Khazali on 7/7/25.
//

import Foundation

class TradingViewModel: ObservableObject {
    @Published var currentSignal: String = "HOLD"
    @Published var currentPrice: String = "--"
    @Published var lastTrade: Trade? = nil
    @Published var tradeHistory: [Trade] = []
    @Published var isBotRunning: Bool = false
    @Published var lastUpdated: Date = Date()

    let webSocket = WebSocketService()
    @Published var chartDataJSON: String = "[]"

    private func updateChartJSON() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let formattedPoints = webSocket.priceHistory.map { point in
            [
                "time": formatter.string(from: point.timestamp),
                "value": point.price
            ]
        }

        if let data = try? JSONSerialization.data(withJSONObject: formattedPoints),
           let json = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.chartDataJSON = json.replacingOccurrences(of: "\"", with: "\\\"")
            }
        }
    }

    func toggleBot() {
        isBotRunning.toggle()
        if isBotRunning {
            connectToWebSocket()
        } else {
            webSocket.disconnect()
            print("🛑 WebSocket disconnected")
        }
    }

    func connectToWebSocket() {
        webSocket.onChartUpdate = { [weak self] in
            self?.updateChartJSON()
        }

        webSocket.onSignalReceived = { [weak self] signal, price in
            DispatchQueue.main.async {
                self?.currentSignal = signal
                self?.currentPrice = price
                self?.lastUpdated = Date()

                if signal != "HOLD" {
                    let newTrade = Trade(type: signal, price: price, date: Date())
                    self?.lastTrade = newTrade
                    self?.tradeHistory.insert(newTrade, at: 0)
                }
            }
            print("📥 Received from WebSocket: signal = \(signal), price = \(price)")
        }

        webSocket.connect()
    }
}
