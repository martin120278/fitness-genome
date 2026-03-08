// View+Extensions.swift
// FitnessGenome
// Modificadores de vista reutilizables

import SwiftUI

extension View {

    // MARK: - Tarjeta con sombra estilo app
    func cardStyle(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Botón primario de la app
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.fgGreen)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Botón secundario
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(Color.fgGreen)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.fgGreen.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Animación de aparición
    func fadeInOnAppear(delay: Double = 0) -> some View {
        self.modifier(FadeInModifier(delay: delay))
    }

    // MARK: - Deshabilitar con overlay visual
    func disabled(_ disabled: Bool, opacity: Double = 0.4) -> some View {
        self
            .disabled(disabled)
            .opacity(disabled ? opacity : 1.0)
    }
}

// MARK: - Fade in modifier

struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                    appeared = true
                }
            }
    }
}
