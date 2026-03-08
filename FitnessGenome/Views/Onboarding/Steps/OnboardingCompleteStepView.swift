// OnboardingCompleteStepView.swift
// FitnessGenome
// Pantalla final del onboarding — resumen del Fitness Genome inicial

import SwiftUI

struct OnboardingCompleteStepView: View {
    @Bindable var vm: OnboardingViewModel
    let onFinish: () -> Void

    @State private var animateGenome = false
    @State private var showDetails = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Genome visual
                genomeVisualization
                    .padding(.top, 20)

                // Resumen del perfil
                profileSummary
                    .fadeInOnAppear(delay: 0.4)

                // Dimensiones del genome
                if showDetails {
                    genomeDimensions
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                // Botón ver plan
                finishButton
                    .fadeInOnAppear(delay: 0.6)

                Spacer(minLength: 16)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.spring(duration: 1.0).delay(0.2)) {
                animateGenome = true
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.8)) {
                showDetails = true
            }
        }
    }

    // MARK: - Genome visual (animado)

    private var genomeVisualization: some View {
        VStack(spacing: 16) {
            ZStack {
                // Anillos pulsantes
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.fgGreen.opacity(0.2 - Double(i) * 0.05), lineWidth: 1.5)
                        .frame(width: 100 + CGFloat(i) * 40, height: 100 + CGFloat(i) * 40)
                        .scaleEffect(animateGenome ? 1.0 : 0.6)
                        .animation(.spring(duration: 0.8).delay(Double(i) * 0.15), value: animateGenome)
                }

                // DNA icon central
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.fgGreen, .fgBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)

                    Image(systemName: "dna")
                        .font(.system(size: 38))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(animateGenome ? 0 : -30))
                        .animation(.spring(duration: 1.0), value: animateGenome)
                }
                .scaleEffect(animateGenome ? 1.0 : 0.5)
                .animation(.spring(duration: 0.7), value: animateGenome)
            }
            .frame(height: 200)

            VStack(spacing: 6) {
                Text("Tu Fitness Genome")
                    .font(.title2.bold())
                Text("Perfil inicial calibrado · v1")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Resumen del perfil

    private var profileSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Resumen de tu perfil")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                SummaryTile(label: "Nombre", value: vm.userName, icon: "person.fill", color: .fgBlue)
                SummaryTile(
                    label: "Nivel",
                    value: vm.overallFitnessLevel.displayName,
                    icon: "chart.bar.fill",
                    color: .fgGreen
                )
                SummaryTile(
                    label: "Objetivo",
                    value: vm.primaryGoal.displayName,
                    icon: vm.primaryGoal.icon,
                    color: .fgOrange
                )
                SummaryTile(
                    label: "Días/semana",
                    value: "\(Int(vm.availableDaysPerWeek)) días",
                    icon: "calendar",
                    color: .fgPurple
                )
                SummaryTile(
                    label: "Sesión",
                    value: "\(Int(vm.sessionDurationMinutes)) min",
                    icon: "clock.fill",
                    color: .fgBlue
                )
                SummaryTile(
                    label: "Sueño",
                    value: String(format: "%.1fh", vm.averageSleepHours),
                    icon: "moon.fill",
                    color: .fgPurple
                )
            }
        }
    }

    // MARK: - Dimensiones del Genome

    private var genomeDimensions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dimensiones estimadas")
                .font(.subheadline.weight(.semibold))

            let dims: [(String, Double, Color)] = [
                ("Fuerza", estimatedStrength, .fgOrange),
                ("Resistencia", estimatedEndurance, .fgBlue),
                ("Movilidad", estimatedMobility, .fgPurple),
                ("Recuperación", estimatedRecovery, .fgGreen)
            ]

            ForEach(dims, id: \.0) { name, value, color in
                GenomeDimensionBar(name: name, value: value, color: color)
            }

            Text("Estas dimensiones evolucionarán con cada sesión.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .cardStyle()
    }

    private var estimatedStrength: Double {
        let level = Double(vm.overallFitnessLevel.numericValue) / 4.0
        let exp = (vm.disciplineExperience[.weightTraining] ?? .none).numericFactor
        return (level * 0.6 + exp * 0.4).clamped(to: 0...1)
    }

    private var estimatedEndurance: Double {
        let level = Double(vm.overallFitnessLevel.numericValue) / 4.0
        let expRun = (vm.disciplineExperience[.running] ?? .none).numericFactor
        let expCyc = (vm.disciplineExperience[.cycling] ?? .none).numericFactor
        return (level * 0.5 + (expRun + expCyc) / 2 * 0.5).clamped(to: 0...1)
    }

    private var estimatedMobility: Double {
        let expYoga = (vm.disciplineExperience[.yoga] ?? .none).numericFactor
        let expPilates = (vm.disciplineExperience[.pilates] ?? .none).numericFactor
        let base = Double(vm.overallFitnessLevel.numericValue) / 4.0 * 0.4
        return (base + (expYoga + expPilates) / 2 * 0.6).clamped(to: 0...1)
    }

    private var estimatedRecovery: Double {
        let sleepFactor = min(vm.averageSleepHours / 8.0, 1.0)
        let stressFactor = 1.0 - Double(vm.stressLevel.numericValue) / 3.0
        return (sleepFactor * 0.6 + stressFactor * 0.4).clamped(to: 0...1)
    }

    // MARK: - Botón finalizar

    private var finishButton: some View {
        Button {
            Task { await handleFinish() }
        } label: {
            HStack(spacing: 10) {
                if vm.isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Ver mi plan semanal")
                        .font(.headline)
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [.fgGreen, .fgBlue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.fgGreen.opacity(0.4), radius: 12, x: 0, y: 4)
        }
        .disabled(vm.isSaving)
    }

    private func handleFinish() async {
        onFinish()
    }
}

// MARK: - Componentes auxiliares

private struct SummaryTile: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .cardStyle(cornerRadius: 12)
    }
}

private struct GenomeDimensionBar: View {
    let name: String
    let value: Double
    let color: Color

    @State private var animated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.caption.weight(.medium))
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.15))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * (animated ? value : 0))
                        .animation(.spring(duration: 0.9).delay(0.2), value: animated)
                }
            }
            .frame(height: 8)
            .onAppear { animated = true }
        }
    }
}

// MARK: - Comparable clamped helper

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

#Preview {
    let vm = OnboardingViewModel()
    vm.userName = "Martín"
    vm.overallFitnessLevel = .intermediate
    vm.availableDaysPerWeek = 4
    vm.sessionDurationMinutes = 60
    vm.primaryGoal = .muscleGain
    return OnboardingCompleteStepView(vm: vm, onFinish: {})
}
