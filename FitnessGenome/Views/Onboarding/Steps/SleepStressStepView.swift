// SleepStressStepView.swift
// FitnessGenome
// Paso 7: Sueño y nivel de estrés

import SwiftUI

struct SleepStressStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                stepHeader
                    .fadeInOnAppear(delay: 0.0)

                sleepSection
                    .fadeInOnAppear(delay: 0.15)

                stressSection
                    .fadeInOnAppear(delay: 0.3)

                recoveryInsight
                    .fadeInOnAppear(delay: 0.45)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    // MARK: - Header

    private var stepHeader: some View {
        VStack(spacing: 6) {
            Text("Descanso y bienestar")
                .font(.title2.bold())
            Text("El sueño y el estrés determinan\ncuánto y cómo puedes entrenar.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Sueño

    private var sleepSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Horas de sueño promedio", systemImage: "moon.zzz.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Text(String(format: "%.1f h", vm.averageSleepHours))
                    .font(.subheadline.bold())
                    .foregroundStyle(sleepColor)
            }

            Slider(value: $vm.averageSleepHours, in: 4...10, step: 0.5)
                .tint(sleepColor)

            HStack {
                Text("4h").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("10h").font(.caption).foregroundStyle(.secondary)
            }

            // Barra de calidad del sueño
            HStack(spacing: 4) {
                ForEach(0..<10) { i in
                    let threshold = Double(i) * 0.6 + 4.0   // 4-10
                    RoundedRectangle(cornerRadius: 2)
                        .fill(vm.averageSleepHours >= threshold ? sleepColor : Color.secondary.opacity(0.2))
                        .frame(height: 8)
                        .animation(.easeInOut(duration: 0.2), value: vm.averageSleepHours)
                }
            }

            Text(sleepQualityLabel)
                .font(.caption)
                .foregroundStyle(sleepColor)
        }
        .padding(16)
        .cardStyle()
    }

    private var sleepColor: Color {
        switch vm.averageSleepHours {
        case ..<6:      return .red
        case 6..<7:     return .orange
        case 7..<8.5:   return .green
        default:        return .blue
        }
    }

    private var sleepQualityLabel: String {
        switch vm.averageSleepHours {
        case ..<5.5:    return "Privación severa — el plan prioriza recuperación"
        case 5.5..<6.5: return "Sueño insuficiente — incluiremos más recuperación"
        case 6.5..<7.5: return "Aceptable — hay margen de mejora"
        case 7.5..<9:   return "Excelente — puedes manejar mayor intensidad"
        default:        return "Mucho sueño — verificar calidad vs cantidad"
        }
    }

    // MARK: - Estrés

    private var stressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Nivel de estrés habitual", systemImage: "brain.head.profile")
                .font(.subheadline.weight(.semibold))

            ForEach(StressLevel.allCases) { level in
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        vm.stressLevel = level
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: stressIcon(level))
                            .font(.title3)
                            .foregroundStyle(vm.stressLevel == level ? .white : stressColor(level))
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(level.displayName)
                                .font(.subheadline.weight(vm.stressLevel == level ? .semibold : .regular))
                            Text(level.description)
                                .font(.caption)
                                .opacity(0.8)
                        }
                        .foregroundStyle(vm.stressLevel == level ? .white : .primary)

                        Spacer()

                        if vm.stressLevel == level {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(12)
                    .background(vm.stressLevel == level ? stressColor(level) : Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .animation(.spring(duration: 0.25), value: vm.stressLevel)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .cardStyle()
    }

    private func stressIcon(_ level: StressLevel) -> String {
        switch level {
        case .low:      return "leaf.fill"
        case .moderate: return "wind"
        case .high:     return "flame.fill"
        case .veryHigh: return "bolt.trianglebadge.exclamationmark.fill"
        }
    }

    private func stressColor(_ level: StressLevel) -> Color {
        switch level {
        case .low:      return .green
        case .moderate: return .yellow
        case .high:     return .orange
        case .veryHigh: return .red
        }
    }

    // MARK: - Insight de recuperación

    private var recoveryInsight: some View {
        let sleepOk = vm.averageSleepHours >= 7
        let stressOk = vm.stressLevel == .low || vm.stressLevel == .moderate
        let bothOk = sleepOk && stressOk

        return HStack(alignment: .top, spacing: 10) {
            Image(systemName: bothOk ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(bothOk ? .green : .orange)
                .font(.subheadline)

            VStack(alignment: .leading, spacing: 4) {
                Text(bothOk ? "Buena capacidad de recuperación" : "Ajustaremos el plan a tu recuperación")
                    .font(.caption.weight(.semibold))
                Text(bothOk
                     ? "Con estos parámetros puedes manejar mayor volumen e intensidad."
                     : "Con menos sueño o más estrés, necesitas más días de recuperación. Tu plan lo considerará.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .cardStyle(cornerRadius: 12)
    }
}

#Preview {
    SleepStressStepView(vm: OnboardingViewModel())
}
