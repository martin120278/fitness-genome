// Color+Extensions.swift
// FitnessGenome
// Paleta de colores de la app — soporta dark mode automáticamente

import SwiftUI

extension Color {
    // MARK: - Colores primarios de la app
    static let fgPrimary    = Color("FGPrimary")      // Verde vibrante principal
    static let fgSecondary  = Color("FGSecondary")    // Azul energía
    static let fgAccent     = Color("FGAccent")       // Naranja motivación

    // MARK: - Fallbacks (usados hasta tener Assets)
    static let fgGreen      = Color(red: 0.13, green: 0.85, blue: 0.52)
    static let fgBlue       = Color(red: 0.20, green: 0.55, blue: 1.00)
    static let fgOrange     = Color(red: 1.00, green: 0.50, blue: 0.15)
    static let fgPurple     = Color(red: 0.65, green: 0.35, blue: 1.00)

    // MARK: - Gradiente principal
    static let fgGradient = LinearGradient(
        colors: [.fgGreen, .fgBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Categorías de actividad
    static func color(for category: ActivityCategory) -> Color {
        switch category {
        case .strength:     return .fgOrange
        case .cardio:       return .fgBlue
        case .mindBody:     return .fgPurple
        case .recreational: return .fgGreen
        }
    }

    // MARK: - Intensidad de sesión
    static func color(for intensity: SessionIntensity) -> Color {
        switch intensity {
        case .recovery:  return .blue
        case .light:     return .green
        case .moderate:  return .yellow
        case .hard:      return .orange
        case .maxEffort: return .red
        }
    }
}
