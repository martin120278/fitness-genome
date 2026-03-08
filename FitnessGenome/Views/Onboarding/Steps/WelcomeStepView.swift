// WelcomeStepView.swift
// FitnessGenome
// Pantalla de bienvenida — primer impacto de la app

import SwiftUI

struct WelcomeStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo / Hero visual
            heroSection
                .fadeInOnAppear(delay: 0.1)

            Spacer()

            // Formulario nombre
            nameSection
                .fadeInOnAppear(delay: 0.4)

            Spacer(minLength: 32)
        }
    }

    private var heroSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.fgGreen.opacity(0.3), .fgBlue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)

                Image(systemName: "dna")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.fgGreen, .fgBlue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 8) {
                Text("Fitness Genome")
                    .font(.largeTitle.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.fgGreen, .fgBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Descubre tu combinación ideal\nde actividades físicas")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Tres bullets de propuesta de valor
            VStack(alignment: .leading, spacing: 12) {
                FeatureBullet(
                    icon: "sparkles",
                    text: "Plan 100% personalizado a tu cuerpo y objetivos"
                )
                FeatureBullet(
                    icon: "arrow.triangle.2.circlepath",
                    text: "Se adapta semana a semana según tus resultados"
                )
                FeatureBullet(
                    icon: "heart.fill",
                    text: "Integrado con Apple Health y Apple Watch"
                )
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 32)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("¿Cómo te llamas?")
                .font(.headline)
                .padding(.horizontal, 20)

            TextField("Tu nombre", text: $vm.userName)
                .font(.title3)
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            vm.userName.isEmpty ? Color.secondary.opacity(0.3) : Color.fgGreen,
                            lineWidth: 1.5
                        )
                )
                .padding(.horizontal, 20)
                .textContentType(.givenName)
                .autocorrectionDisabled()
                .submitLabel(.done)
        }
    }
}

// MARK: - Bullet de feature

private struct FeatureBullet: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.fgGreen)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    let vm = OnboardingViewModel()
    return WelcomeStepView(vm: vm)
}
