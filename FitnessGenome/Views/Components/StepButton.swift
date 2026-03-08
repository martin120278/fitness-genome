// StepButton.swift
// FitnessGenome
// Botón reutilizable para navegar entre pasos del onboarding

import SwiftUI

struct StepNavigationButtons: View {
    let canProceed: Bool
    let isLastStep: Bool
    let isFirstStep: Bool
    let isLoading: Bool
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Botón Atrás
            if !isFirstStep {
                Button(action: onBack) {
                    Label("Atrás", systemImage: "chevron.left")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(.background.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            // Botón Siguiente / Finalizar
            Button(action: onNext) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.85)
                    } else {
                        Text(isLastStep ? "Ver mi plan" : "Continuar")
                            .font(.headline)
                    }
                    if !isLoading && !isLastStep {
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.bold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canProceed && !isLoading ? Color.fgGreen : Color.secondary.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .animation(.easeInOut(duration: 0.2), value: canProceed)
            }
            .disabled(!canProceed || isLoading)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}

// MARK: - Chip de selección reutilizable

struct SelectionChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline)
                }
                Text(title)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color.fgGreen : Color.secondary.opacity(0.12))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.fgGreen : Color.clear, lineWidth: 1.5)
            )
            .animation(.spring(duration: 0.25), value: isSelected)
        }
    }
}

// MARK: - Tarjeta de opción grande

struct OptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.fgGreen : Color.secondary.opacity(0.12))
                        .frame(width: 46, height: 46)
                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(isSelected ? .white : .secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.fgGreen : Color.secondary.opacity(0.4))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.fgGreen.opacity(0.08) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.fgGreen : Color.secondary.opacity(0.2), lineWidth: 1.5)
                    )
            )
            .animation(.spring(duration: 0.25), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        StepNavigationButtons(
            canProceed: true,
            isLastStep: false,
            isFirstStep: false,
            isLoading: false,
            onNext: {},
            onBack: {}
        )

        HStack {
            SelectionChip(title: "Running", icon: "figure.run", isSelected: true, action: {})
            SelectionChip(title: "Yoga", icon: "figure.yoga", isSelected: false, action: {})
        }

        OptionCard(
            title: "Principiante",
            subtitle: "Ejercicio ocasional, menos de 6 meses",
            icon: "figure.walk",
            isSelected: true,
            action: {}
        )
    }
    .padding()
}
