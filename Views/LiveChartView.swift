//
//  LiveChartView.swift
//  BlueTradingApp
//
//  Created by Ali Al-Khazali on 7/8/25.
//

import SwiftUI
import WebKit

struct LiveChartView: View {
    @ObservedObject var webSocket: WebSocketService
    @Binding var jsonPriceData: String

    @State private var webView = WKWebView()
    @State private var isPageLoaded = false
    @State private var latestPendingData: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("EUR/USD Live Chart")
                .font(.headline)
                .padding(.bottom, 4)

            WebViewWrapper(webView: webView)
                .frame(height: 240)
                .onAppear {
                    if let url = Bundle.main.url(forResource: "chart", withExtension: "html", subdirectory: "Resources/Charts") {
                        print("🌐 Loading chart.html...")
                        webView.navigationDelegate = WebViewDelegate(isLoaded: $isPageLoaded)
                        webView.loadFileURL(url, allowingReadAccessTo: url)
                    }
                }
                .onChange(of: isPageLoaded) { loaded in
                    print("🟢 Page loaded: \(loaded)")
                    if loaded {
                        sendChartData(latestPendingData)
                    }
                }
                .onChange(of: jsonPriceData) { newValue in
                    print("📦 New chart data received")
                    latestPendingData = newValue
                    if isPageLoaded {
                        sendChartData(newValue)
                    }
                }
        }
        .padding()
    }

    private func sendChartData(_ json: String) {
        let js = "window.updateChartData('\(json)')"
        webView.evaluateJavaScript(js) { _, error in
            if let error = error {
                print("❌ JavaScript error: \(error.localizedDescription)")
            } else {
                print("✅ Chart updated with new data")
            }
        }
    }
}

struct WebViewWrapper: NSViewRepresentable {
    let webView: WKWebView
    func makeNSView(context: Context) -> WKWebView { webView }
    func updateNSView(_ nsView: WKWebView, context: Context) {}
}

class WebViewDelegate: NSObject, WKNavigationDelegate {
    @Binding var isLoaded: Bool
    init(isLoaded: Binding<Bool>) {
        _isLoaded = isLoaded
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ chart.html finished loading")
        isLoaded = true
    }
}
