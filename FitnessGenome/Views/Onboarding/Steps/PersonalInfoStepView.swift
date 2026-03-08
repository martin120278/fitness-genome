// PersonalInfoStepView.swift
// FitnessGenome
// Paso 2: Datos personales — edad, sexo, altura, peso

import SwiftUI

struct PersonalInfoStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                stepHeader

                // Sexo biológico
                sexSection
                    .fadeInOnAppear(delay: 0.1)

                // Edad
                ageSection
                    .fadeInOnAppear(delay: 0.2)

                // Altura
                heightSection
                    .fadeInOnAppear(delay: 0.3)

                // Peso
                weightSection
                    .fadeInOnAppear(delay: 0.4)

                // BMI informativo
                if vm.heightCm > 0 && vm.weightKg > 0 {
                    bmiCard
                        .fadeInOnAppear(delay: 0.5)
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    // MARK: - Header del paso

    private var stepHeader: some View {
        VStack(spacing: 6) {
            Text("Hola, \(vm.userName.isEmpty ? "allí" : vm.userName)!")
                .font(.title2.bold())
            Text("Necesitamos algunos datos básicos\npara calibrar tu Fitness Genome.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Sexo biológico

    private var sexSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Sexo biológico", info: "Usado para calcular estimaciones de calorías y HR")

            HStack(spacing: 10) {
                ForEach(BiologicalSex.allCases, id: \.self) { sex in
                    Button {
                        withAnimation(.spring(duration: 0.3)) { vm.sex = sex }
                    } label: {
                        Text(sex.displayName)
                            .font(.subheadline.weight(vm.sex == sex ? .semibold : .regular))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(vm.sex == sex ? Color.fgGreen : Color.secondary.opacity(0.1))
                            .foregroundStyle(vm.sex == sex ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    // MARK: - Edad

    private var ageSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Edad", value: "\(Int(vm.age)) años")

            Slider(value: $vm.age, in: 14...80, step: 1)
                .tint(Color.fgGreen)

            HStack {
                Text("14").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("80").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Altura

    private var heightSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Altura", value: "\(Int(vm.heightCm)) cm")

            Slider(value: $vm.heightCm, in: 140...220, step: 1)
                .tint(Color.fgGreen)

            HStack {
                Text("140 cm").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("220 cm").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Peso

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Peso", value: String(format: "%.1f kg", vm.weightKg))

            Slider(value: $vm.weightKg, in: 40...200, step: 0.5)
                .tint(Color.fgGreen)

            HStack {
                Text("40 kg").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("200 kg").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - BMI Card

    private var bmiCard: some View {
        let heightM = vm.heightCm / 100
        let bmi = vm.weightKg / (heightM * heightM)
        let category = bmiCategory(bmi)

        return HStack(spacing: 14) {
            Image(systemName: "chart.bar.fill")
                .font(.title2)
                .foregroundStyle(category.color)

            VStack(alignment: .leading, spacing: 2) {
                Text("IMC: \(String(format: "%.1f", bmi))")
                    .font(.headline)
                Text(category.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("Informativo")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .cardStyle()
    }

    // MARK: - Helpers

    private func sectionLabel(_ title: String, value: String? = nil, info: String? = nil) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            if let value {
                Spacer()
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.fgGreen)
            }
            if let info {
                Spacer()
                Text(info)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private struct BMICategory {
        let label: String
        let color: Color
    }

    private func bmiCategory(_ bmi: Double) -> BMICategory {
        switch bmi {
        case ..<18.5: return BMICategory(label: "Bajo peso", color: .blue)
        case 18.5..<25: return BMICategory(label: "Peso normal", color: .green)
        case 25..<30: return BMICategory(label: "Sobrepeso", color: .orange)
        default: return BMICategory(label: "Obesidad", color: .red)
        }
    }
}

#Preview {
    PersonalInfoStepView(vm: OnboardingViewModel())
}
