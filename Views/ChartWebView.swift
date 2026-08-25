//
//  ChartWebView.swift
//  BlueTradingApp
//
//  Created by Ali Al-Khazali on 7/9/25.
//

import SwiftUI
import WebKit

struct ChartWebView: NSViewRepresentable {
    @Binding var jsonPriceData: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        if let url = Bundle.main.url(forResource: "chart", withExtension: "html", subdirectory: "Resources/Charts") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }

        context.coordinator.webView = webView
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.jsonPriceData = jsonPriceData
        context.coordinator.sendChartDataIfReady()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ChartWebView
        var jsonPriceData: String = ""
        var isPageLoaded = false
        weak var webView: WKWebView?

        init(_ parent: ChartWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isPageLoaded = true
            print("✅ HTML page finished loading")

            sendChartDataIfReady()
        }

        func sendChartDataIfReady() {
            guard isPageLoaded, let webView = webView else { return }
            let js = "window.updateChartData('\(jsonPriceData)')"
            print("📤 Running JS: \(js.prefix(100))...") // عرض أول 100 حرف
            webView.evaluateJavaScript(js) { result, error in
                if let error = error {
                    print("❌ JavaScript eval failed: \(error.localizedDescription)")
                } else {
                    print("✅ Chart updated")
                }
            }
        }
    }
}
