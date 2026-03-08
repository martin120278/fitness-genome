// OnboardingProgressBar.swift
// FitnessGenome
// Barra de progreso del onboarding con indicadores de paso

import SwiftUI

struct OnboardingProgressBar: View {
    let currentStep: OnboardingStep
    let totalSteps: Int

    private var progress: Double {
        // Excluimos welcome (0) y complete (last) del conteo visible
        let usableSteps = OnboardingStep.allCases.filter { $0.showsProgress }
        guard let index = usableSteps.firstIndex(of: currentStep) else { return 0 }
        return Double(index + 1) / Double(usableSteps.count)
    }

    private var stepNumber: Int {
        let usableSteps = OnboardingStep.allCases.filter { $0.showsProgress }
        return (usableSteps.firstIndex(of: currentStep) ?? 0) + 1
    }

    private var totalVisibleSteps: Int {
        OnboardingStep.allCases.filter { $0.showsProgress }.count
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Paso \(stepNumber) de \(totalVisibleSteps)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(Color.fgGreen)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.fgGreen, .fgBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.spring(duration: 0.5), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressBar(currentStep: .personalInfo, totalSteps: 8)
        OnboardingProgressBar(currentStep: .goals, totalSteps: 8)
        OnboardingProgressBar(currentStep: .sleepStress, totalSteps: 8)
    }
    .padding()
}
