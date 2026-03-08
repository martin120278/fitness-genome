// DisciplineExperienceStepView.swift
// FitnessGenome
// Paso 8: Experiencia por disciplina de fitness

import SwiftUI

struct DisciplineExperienceStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                stepHeader
                    .fadeInOnAppear(delay: 0.0)

                disciplineList
                    .fadeInOnAppear(delay: 0.15)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    private var stepHeader: some View {
        VStack(spacing: 6) {
            Text("Tu experiencia en\ncada disciplina")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Sé honesto — esto calibra tu Fitness Genome inicial.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var disciplineList: some View {
        VStack(spacing: 12) {
            ForEach(ActivityType.allCases) { activity in
                DisciplineExperienceRow(
                    activity: activity,
                    selectedLevel: Binding(
                        get: { vm.disciplineExperience[activity] ?? .none },
                        set: { vm.disciplineExperience[activity] = $0 }
                    )
                )
            }
        }
    }
}

// MARK: - Fila de disciplina

private struct DisciplineExperienceRow: View {
    let activity: ActivityType
    @Binding var selectedLevel: ExperienceLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: activity.icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.color(for: activity.category))
                    .frame(width: 24)

                Text(activity.displayName)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text(selectedLevel.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                ForEach(ExperienceLevel.allCases) { level in
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedLevel = level
                        }
                    } label: {
                        Text(level.shortName)
                            .font(.caption.weight(selectedLevel == level ? .semibold : .regular))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedLevel == level
                                ? Color.color(for: activity.category)
                                : Color.secondary.opacity(0.1)
                            )
                            .foregroundStyle(selectedLevel == level ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(14)
        .cardStyle()
    }
}

#Preview {
    DisciplineExperienceStepView(vm: OnboardingViewModel())
}
