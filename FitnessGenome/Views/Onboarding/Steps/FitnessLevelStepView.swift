// FitnessLevelStepView.swift
// FitnessGenome
// Paso 3: Nivel actual de fitness

import SwiftUI

struct FitnessLevelStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                stepHeader
                    .fadeInOnAppear(delay: 0.0)

                ForEach(Array(FitnessLevel.allCases.enumerated()), id: \.element) { index, level in
                    OptionCard(
                        title: level.displayName,
                        subtitle: level.description,
                        icon: icon(for: level),
                        isSelected: vm.overallFitnessLevel == level
                    ) {
                        withAnimation(.spring(duration: 0.3)) {
                            vm.overallFitnessLevel = level
                        }
                    }
                    .fadeInOnAppear(delay: Double(index) * 0.07)
                }

                infoNote
                    .fadeInOnAppear(delay: 0.5)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    private var stepHeader: some View {
        VStack(spacing: 6) {
            Text("¿Cuál es tu nivel\nde fitness actual?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Sé honesto. Esto calibra tu plan inicial.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var infoNote: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
            Text("Tu Fitness Genome se ajustará automáticamente conforme entrenes y des feedback.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .cardStyle(cornerRadius: 12)
    }

    private func icon(for level: FitnessLevel) -> String {
        switch level {
        case .sedentary:    return "figure.stand"
        case .beginner:     return "figure.walk"
        case .intermediate: return "figure.run"
        case .advanced:     return "figure.strengthtraining.traditional"
        case .athlete:      return "trophy.fill"
        }
    }
}

#Preview {
    FitnessLevelStepView(vm: OnboardingViewModel())
}
