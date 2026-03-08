// InjuriesStepView.swift
// FitnessGenome
// Paso 4: Lesiones y limitaciones físicas

import SwiftUI

struct InjuriesStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                stepHeader
                    .fadeInOnAppear(delay: 0.0)

                injuriesGrid
                    .fadeInOnAppear(delay: 0.15)

                if !vm.selectedInjuries.isEmpty && !vm.selectedInjuries.contains(.none) {
                    notesSection
                        .fadeInOnAppear(delay: 0.0)
                }

                importanceNote
                    .fadeInOnAppear(delay: 0.3)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    // MARK: - Header

    private var stepHeader: some View {
        VStack(spacing: 6) {
            Text("¿Tienes alguna lesión\no limitación?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Adaptaremos el plan para protegerte.\nPuedes seleccionar varias.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Grid de lesiones

    private var injuriesGrid: some View {
        let injuries = InjuryType.allCases

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(injuries) { injury in
                InjuryChip(
                    injury: injury,
                    isSelected: injuryIsSelected(injury)
                ) {
                    toggleInjury(injury)
                }
            }
        }
    }

    // MARK: - Notas adicionales

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Detalles adicionales (opcional)")
                .font(.subheadline.weight(.semibold))

            TextField(
                "Ej: Hernia discal L4-L5, no puedo cargar más de 20 kg...",
                text: $vm.injuryNotes,
                axis: .vertical
            )
            .font(.subheadline)
            .lineLimit(3...5)
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Nota de importancia

    private var importanceNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "shield.checkered")
                .foregroundStyle(Color.fgGreen)
                .font(.subheadline)
            Text("Esta información nunca se comparte y solo se usa para crear ejercicios seguros para ti.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .cardStyle(cornerRadius: 12)
    }

    // MARK: - Lógica de selección

    private func injuryIsSelected(_ injury: InjuryType) -> Bool {
        if injury == .none {
            return vm.selectedInjuries.isEmpty || vm.selectedInjuries.contains(.none)
        }
        return vm.selectedInjuries.contains(injury)
    }

    private func toggleInjury(_ injury: InjuryType) {
        withAnimation(.spring(duration: 0.25)) {
            if injury == .none {
                vm.selectedInjuries = [.none]
            } else {
                vm.selectedInjuries.remove(.none)
                if vm.selectedInjuries.contains(injury) {
                    vm.selectedInjuries.remove(injury)
                } else {
                    vm.selectedInjuries.insert(injury)
                }
            }
        }
    }
}

// MARK: - Chip de lesión

private struct InjuryChip: View {
    let injury: InjuryType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: iconFor(injury))
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : Color.fgOrange)

                Text(injury.displayName)
                    .font(.caption.weight(isSelected ? .semibold : .regular))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(isSelected ? Color.fgOrange : Color.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.fgOrange : Color.clear, lineWidth: 1.5)
            )
            .animation(.spring(duration: 0.25), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    private func iconFor(_ injury: InjuryType) -> String {
        switch injury {
        case .none:      return "checkmark.shield.fill"
        case .lowerBack: return "figure.walk.motion"
        case .knee:      return "figure.run.treadmill"
        case .shoulder:  return "figure.arms.open"
        case .hip:       return "figure.walk"
        case .ankle:     return "shoeprints.fill"
        case .wrist:     return "hand.raised.fill"
        case .neck:      return "figure.mind.and.body"
        case .elbow:     return "figure.strengthtraining.traditional"
        }
    }
}

#Preview {
    InjuriesStepView(vm: OnboardingViewModel())
}
