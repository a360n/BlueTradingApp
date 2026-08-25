//
//  HomeView.swift
//  BlueTradingApp
//
//  Created by Ali Al-Khazali on 7/7/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = TradingViewModel()
    @StateObject private var theme = ThemeManager()
    var webSocket: WebSocketService?
    var body: some View {
        ZStack {
            theme.colors.background.ignoresSafeArea() // 🔧 خلفية متناسقة مع الثيم

            VStack(spacing: 20) {
                HStack {
                    Label("Blue Trading", systemImage: "chart.bar.doc.horizontal")
                        .font(.largeTitle.bold())
                        .foregroundColor(theme.currentTheme == .light ? AppColors.Light.primary : AppColors.Dark.secondary)

                    Spacer()

                    Button(action: {
                        theme.toggleTheme()
                    }) {
                        Label("Toggle Theme", systemImage: theme.currentTheme == .light ? "moon.fill" : "sun.max.fill")
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(theme.colors.accent.opacity(0.15))
                            .foregroundColor(theme.colors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(theme.colors.accent, lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                LiveSignalView(
                    signal: vm.currentSignal,
                    price: vm.currentPrice,
                    lastUpdated: vm.lastUpdated
                )
                .environmentObject(theme)
                if vm.isBotRunning {
                    LiveChartView(webSocket: vm.webSocket, jsonPriceData: $vm.chartDataJSON)
                        .onAppear {
                            print("📊 JSON Preview: \(vm.chartDataJSON.prefix(200))")
                        }
                }
                if let last = vm.lastTrade {
                    Text("Last Trade: \(last.type) at \(last.price)")
                        .foregroundColor(theme.colors.accent)
                } else {
                    Text("No trades yet")
                        .foregroundColor(theme.colors.text)
                }

                List(vm.tradeHistory) { trade in
                    HStack(spacing: 16) {
                        Label(trade.type, systemImage: trade.type == "BUY" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .foregroundColor(trade.type == "BUY" ? .green : .red)
                            .labelStyle(TitleOnlyLabelStyle())
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Price: \(trade.price)")
                                .font(.subheadline)
                                .foregroundColor(theme.colors.text)

                            Text(trade.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(theme.colors.text.opacity(0.6))
                        }

                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(theme.currentTheme == .light ? AppColors.Light.neutral : AppColors.Dark.primary.opacity(0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.colors.accent.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.vertical, 4)
                    .listRowSeparator(.hidden) // macOS 13+
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .listStyle(.plain)

                Button(vm.isBotRunning ? "Stop Bot" : "Start Bot") {
                    vm.toggleBot()
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.colors.accent)
            }
            .padding()
            .frame(minWidth: 600, minHeight: 500)
            .animation(.easeInOut, value: theme.currentTheme)
        }
    }
}
