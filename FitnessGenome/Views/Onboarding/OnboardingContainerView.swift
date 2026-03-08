// OnboardingContainerView.swift
// FitnessGenome
// Contenedor principal que orquesta todos los pasos del onboarding

import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = OnboardingViewModel()
    let onComplete: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            // Fondo
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header con progreso
                if vm.currentStep.showsProgress {
                    headerBar
                        .transition(.opacity)
                }

                // Contenido del paso actual
                stepContent
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )
                    .id(vm.currentStep)

                // Botones de navegación
                if vm.currentStep != .complete {
                    StepNavigationButtons(
                        canProceed: vm.canProceed,
                        isLastStep: vm.currentStep == .activityPreferences,
                        isFirstStep: vm.isFirstStep,
                        isLoading: vm.isSaving,
                        onNext: handleNext,
                        onBack: { vm.goToPreviousStep() }
                    )
                    .padding(.top, 8)
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: vm.currentStep)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.fgGreen.opacity(0.04),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Header bar

    private var headerBar: some View {
        VStack(spacing: 12) {
            // Título del paso
            HStack {
                // Botón X para saltar (solo si ya hay datos)
                Spacer()
                VStack(spacing: 2) {
                    Text(vm.currentStep.title)
                        .font(.headline)
                    Text(vm.currentStep.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            OnboardingProgressBar(
                currentStep: vm.currentStep,
                totalSteps: OnboardingStep.allCases.filter { $0.showsProgress }.count
            )
            .padding(.bottom, 8)
        }
    }

    // MARK: - Step content

    @ViewBuilder
    private var stepContent: some View {
        switch vm.currentStep {
        case .welcome:
            WelcomeStepView(vm: vm)

        case .personalInfo:
            PersonalInfoStepView(vm: vm)

        case .fitnessLevel:
            FitnessLevelStepView(vm: vm)

        case .injuries:
            InjuriesStepView(vm: vm)

        case .goals:
            GoalsStepView(vm: vm)

        case .timeEquipment:
            TimeEquipmentStepView(vm: vm)

        case .sleepStress:
            SleepStressStepView(vm: vm)

        case .disciplineExperience:
            DisciplineExperienceStepView(vm: vm)

        case .activityPreferences:
            ActivityPreferencesStepView(vm: vm)

        case .complete:
            OnboardingCompleteStepView(vm: vm) {
                Task { await finishOnboarding() }
            }
        }
    }

    // MARK: - Acciones

    private func handleNext() {
        if vm.currentStep == .activityPreferences {
            // Último paso antes de complete — guardar y mostrar resultado
            Task {
                await vm.saveProfile(context: modelContext)
                if vm.saveError == nil {
                    vm.goToNextStep()
                }
            }
        } else {
            vm.goToNextStep()
        }
    }

    private func finishOnboarding() async {
        onComplete()
    }
}

#Preview {
    OnboardingContainerView(onComplete: {})
        .modelContainer(for: [UserProfile.self, FitnessGenomeModel.self], inMemory: true)
}
