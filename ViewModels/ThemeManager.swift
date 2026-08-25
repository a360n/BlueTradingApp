//
//  ThemeManager.swift
//  BlueTradingApp
//
//  Created by Ali Al-Khazali on 7/7/25.
//

import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    enum Theme {
        case light
        case dark
    }

    @Published var currentTheme: Theme = .dark

    var colors: ThemeColors {
        switch currentTheme {
        case .light:
            return ThemeColors(
                background: AppColors.Light.neutral,
                primary: AppColors.Light.primary,
                secondary: AppColors.Light.secondary,
                accent: AppColors.Light.accent,
                text: Color.black
            )
        case .dark:
            return ThemeColors(
                background: AppColors.Dark.background,
                primary: AppColors.Dark.primary,
                secondary: AppColors.Dark.secondary,
                accent: AppColors.Dark.accent,
                text: Color.white
            )
        }
    }

    func toggleTheme() {
        currentTheme = (currentTheme == .light) ? .dark : .light
    }
}

struct ThemeColors {
    let background: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let text: Color
}
