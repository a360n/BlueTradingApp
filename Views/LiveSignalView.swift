//
//  LiveSignalView.swift
//  BlueTradingApp
//
//  Created by Ali Al-Khazali on 7/8/25.
//

import Foundation
import SwiftUI

struct LiveSignalView: View {
    var signal: String
    var price: String
    var lastUpdated: Date
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: iconName(for: signal))
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(color(for: signal))

            VStack(alignment: .leading, spacing: 6) {
                Text("Signal: \(signal)")
                    .font(.title3.bold())
                    .foregroundColor(theme.colors.text)
                
                Text("Price: \(price)")
                    .foregroundColor(theme.colors.text)
                
                Text("Updated: \(formattedDate(lastUpdated))")
                    .font(.caption)
                    .foregroundColor(theme.colors.text.opacity(0.6))
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(theme.currentTheme == .light ? AppColors.Light.neutral : AppColors.Dark.primary.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(theme.colors.accent.opacity(0.3), lineWidth: 1)
        )
    }

    private func iconName(for signal: String) -> String {
        switch signal {
        case "BUY":
            return "arrow.up.circle.fill"
        case "SELL":
            return "arrow.down.circle.fill"
        default:
            return "pause.circle.fill"
        }
    }

    private func color(for signal: String) -> Color {
        switch signal {
        case "BUY":
            return .green
        case "SELL":
            return .red
        default:
            return .yellow
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
