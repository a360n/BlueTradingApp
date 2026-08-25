<div align="center">

# BlueTradingApp — Real-Time Algorithmic Trading & Market Telemetry Client

[![Swift](https://img.shields.io/badge/Swift-5.9+-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/swift/)
[![iOS](https://img.shields.io/badge/iOS-17.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-MVVM-007ACC?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![WebSockets](https://img.shields.io/badge/WebSockets-Real--Time_Stream-4E9A06?style=for-the-badge&logo=socketdotio&logoColor=white)](https://developer.apple.com/documentation/foundation/urlsessionwebsockettask)
[![Python](https://img.shields.io/badge/Backend-Python_AsyncIO-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

<p align="center">
  A native iOS financial trading client and streaming engine built with <b>SwiftUI</b>, <b>URLSessionWebSocketTask</b>, and a containerized <b>Python AsyncIO</b> telemetry backend.
</p>

</div>

---

## Table of Contents
- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Key Features](#key-features)
- [Client Implementation](#client-implementation)
- [Telemetry Server](#telemetry-server)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Author & License](#author--license)

---

## Overview

**BlueTradingApp** is an asynchronous market monitoring and algorithmic trading interface engineered for iOS. The platform pairs a responsive SwiftUI MVVM client with an event-driven Python WebSocket streaming backend, delivering low-latency tick data, technical charting via embedded WebKit rendering, and automated BUY/SELL/HOLD signal execution.

### Architectural Goals
- **Sub-100ms Telemetry Delivery:** Direct bi-directional WebSocket pipe bypassing HTTP polling overhead.
- **Hardware-Accelerated Charting:** Native WKWebView integration with interactive Lightweight Financial Charts.
- **Resilient Connection Lifecycle:** Auto-reconnect routines, exponential backoff, and state recovery.

---

## System Architecture

```mermaid
flowchart TD
    subgraph External["External Market Data"]
        TwelveData["TwelveData Financial API
(Forex EUR/USD Tick Data)"]
    end

    subgraph Backend["Python Telemetry Server (AsyncIO / Docker)"]
        Ingest["Market Data Ingestion Engine"]
        SignalEngine["Technical Signal Engine
(BUY / SELL / HOLD)"]
        WSServer["WebSockets Server (Port 8002)"]
    end

    subgraph Client["Native iOS Client (SwiftUI / MVVM)"]
        WSTask["URLSessionWebSocketTask Client"]
        ViewModel["TradingViewModel (ObservableObject)"]
        Theme["ThemeManager"]
        
        subgraph UI["SwiftUI Presentation Layer"]
            LiveChart["LiveChartView (WKWebView Bridge)"]
            SignalView["LiveSignalView (Real-Time Badge)"]
            Home["HomeView & Trade History"]
        end
    end

    TwelveData -->|REST / Polling Stream| Ingest
    Ingest --> SignalEngine
    SignalEngine --> WSServer
    WSServer <==>|Bi-directional WebSocket (JSON)| WSTask
    WSTask --> ViewModel
    ViewModel --> LiveChart
    ViewModel --> SignalView
    ViewModel --> Home
    Theme -.-> UI
```

---

## Key Features

### 1. Real-Time Telemetry & Signal Parsing
- Subscribes to live EUR/USD price streams with millisecond-precision timestamps.
- Automated algorithmic signal classification:
  - **BUY:** Bullish momentum indicators trigger actionable visual prompts.
  - **SELL:** Bearish reversal thresholds notify instant exit/entry positions.
  - **HOLD:** Sideways consolidation filter to prevent false breakouts.

### 2. Interactive Lightweight Financial Charting
- Embedded WebKit bridge (`ChartWebView`) hosting interactive HTML5/JavaScript candlestick charts.
- Zero frame-drop rendering with dynamic dataset injection via `evaluateJavaScript`.
- Support for zoom, pan, crosshair inspection, and multi-resolution timeframes.

### 3. Asynchronous Connection Management
- Built on Apple's `URLSessionWebSocketTask` for native performance and background session handling.
- Graceful connection degradation with auto-reconnect fallback loops and status listeners.

### 4. Modular MVVM Architecture
- Clean separation between network transport (`WebSocketService`), presentation state (`TradingViewModel`), and design tokens (`ThemeManager`).

---

## Client Implementation

### WebSocket Client Engine
The client relies on an event-driven loop that asynchronously receives JSON payloads and serializes them into type-safe domain models:

```swift
class WebSocketService: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "ws://127.0.0.1:8002")!
    
    @Published var isConnected = false
    @Published var signal: String = "HOLD"
    @Published var price: String = "--"
    @Published var priceHistory: [PricePoint] = []
    
    func connect() {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        listenForMessages()
    }
    
    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.listenForMessages()
            case .failure(let error):
                self?.handleDisconnection(error)
            }
        }
    }
}
```

---

## Telemetry Server

The Python telemetry bridge provides asynchronous polling and broadcasting to all connected mobile clients:

```
python/server/
├── server.py        # AsyncIO WebSocket Server & TwelveData Ingestion
├── Dockerfile       # Containerized Production Deployment
├── cert.pem         # TLS Certificate for Secure WSS
└── requirements.txt # Dependencies: websockets, requests, asyncio
```

### Running the Server via Docker
```bash
cd python/server
docker build -t blue-trading-server .
docker run -p 8002:8002 blue-trading-server
```

---

## Tech Stack

| Domain | Technology | Purpose |
| :--- | :--- | :--- |
| **iOS Framework** | SwiftUI (iOS 17+) | Reactive Declarative UI |
| **Networking** | URLSessionWebSocketTask | Low-Latency Full-Duplex Socket Stream |
| **Charting Engine** | WebKit / WKWebView | Lightweight JavaScript Financial Charts |
| **Architecture** | MVVM (ObservableObject) | Unidirectional State Management |
| **Backend** | Python 3.11 / AsyncIO | Market Data Ingestion & Signal Calculation |
| **Server Networking**| WebSockets / Requests | Real-Time Broadcast & REST API Client |
| **Containerization** | Docker | Server Deployment & Portability |

---

## Project Structure

```
BlueTradingApp/
├── BlueTradingApp/                  # App Entry & Configurations
│   ├── BlueTradingAppApp.swift      # Main Application Lifecycle
│   ├── ContentView.swift            # Root Container View
│   ├── Info.plist                   # App Metadata & Network Security
│   └── BlueTradingApp.entitlements  # App Sandbox & Network Entitlements
├── Models/                          # Domain Data Models
│   ├── PricePoint.swift             # Timestamp & Price Coordinate Model
│   └── Trade.swift                  # Order Execution & Trade Record Model
├── ViewModels/                      # Presentation Logic
│   ├── TradingViewModel.swift       # Market State & Order History ViewModel
│   └── ThemeManager.swift           # Dynamic Theme Provider
├── Views/                           # SwiftUI Presentation Views
│   ├── HomeView.swift               # Dashboard & Account Overview
│   ├── LiveChartView.swift          # Live Chart Container View
│   ├── ChartWebView.swift           # WKWebView JavaScript Bridge
│   └── LiveSignalView.swift         # Signal Badge & Price Header
├── Services/                        # Networking & Core Services
│   └── WebSocketService.swift       # URLSession WebSocket Implementation
├── Extensions/                      # Utility Extensions
│   └── Color+Hex.swift              # Hex Color Initializer
├── Resources/                       # Web & Visual Assets
│   ├── Colors.swift                 # Named Palette Constants
│   └── Charts/chart.html            # Lightweight Financial Chart Canvas
├── python/server/                   # Backend Streaming Microservice
│   ├── server.py                    # WebSocket Hub
│   ├── Dockerfile                   # Docker Build Spec
│   └── cert.pem                     # WSS Certificate
├── BlueTradingAppTests/             # Unit Tests
└── BlueTradingAppUITests/           # UI Automation Tests
```

---

## Getting Started

### 1. Start the Telemetry Server
Ensure Python 3.10+ is installed:
```bash
cd python/server
pip install -r requirements.txt # websockets requests
python3 server.py
```
The server will bind to `ws://127.0.0.1:8002` and begin streaming real-time market ticks.

### 2. Run the iOS Application
1. Open `BlueTradingApp.xcodeproj` in Xcode 15+.
2. Select an iOS 17.0+ Simulator (e.g., iPhone 15 Pro).
3. Press `Cmd + R` to build and launch the app.
4. The client will automatically connect to the local WebSocket server and initiate live chart streaming.

---

## Author

**Ali Nasser (Ali Al-Khazali)**
- Portfolio: [www.ali-nasser.dev](https://www.ali-nasser.dev)
- GitHub: [@a360n](https://github.com/a360n)
- LinkedIn: [Ali Nasser](https://www.linkedin.com/in/ali-nasser-dev/)

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
