// ActivityPreferencesStepView.swift
// FitnessGenome
// Paso 9: Preferencias de actividades físicas

import SwiftUI

struct ActivityPreferencesStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                stepHeader
                    .fadeInOnAppear(delay: 0.0)

                preferredSection
                    .fadeInOnAppear(delay: 0.15)

                dislikedSection
                    .fadeInOnAppear(delay: 0.3)

                noteCard
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
            Text("¿Qué te gusta\nhacer?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Priorizaremos actividades que disfrutas\nsin eliminar las que necesitas.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Actividades preferidas

    private var preferredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Me gustan o quisiera hacer", systemImage: "heart.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.fgGreen)

            activityGrid(mode: .preferred)
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Actividades que no gustan

    private var dislikedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Prefiero evitar", systemImage: "hand.thumbsdown.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.fgOrange)

            Text("Reduciremos al mínimo estas actividades")
                .font(.caption)
                .foregroundStyle(.secondary)

            activityGrid(mode: .disliked)
        }
        .padding(16)
        .cardStyle()
    }

    private enum GridMode { case preferred, disliked }

    @ViewBuilder
    private func activityGrid(mode: GridMode) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(ActivityType.allCases) { activity in
                ActivityPreferenceChip(
                    activity: activity,
                    state: state(for: activity, mode: mode)
                ) {
                    toggleActivity(activity, mode: mode)
                }
            }
        }
    }

    private enum ChipState { case preferred, disliked, neutral }

    private func state(for activity: ActivityType, mode: GridMode) -> ChipState {
        if vm.preferredActivities.contains(activity) { return .preferred }
        if vm.dislikedActivities.contains(activity) { return .disliked }
        return .neutral
    }

    private func toggleActivity(_ activity: ActivityType, mode: GridMode) {
        withAnimation(.spring(duration: 0.25)) {
            switch mode {
            case .preferred:
                if vm.preferredActivities.contains(activity) {
                    vm.preferredActivities.remove(activity)
                } else {
                    vm.preferredActivities.insert(activity)
                    vm.dislikedActivities.remove(activity)
                }
            case .disliked:
                if vm.dislikedActivities.contains(activity) {
                    vm.dislikedActivities.remove(activity)
                } else {
                    vm.dislikedActivities.insert(activity)
                    vm.preferredActivities.remove(activity)
                }
            }
        }
    }

    // MARK: - Nota

    private var noteCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.fgBlue)
                .font(.subheadline)
            Text("No hay problema si no seleccionas nada. El Fitness Genome aprenderá tus preferencias conforme entrenes.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .cardStyle(cornerRadius: 12)
    }
}

// MARK: - Chip de preferencia de actividad

private struct ActivityPreferenceChip: View {
    let activity: ActivityType

    enum State { case preferred, disliked, neutral }
    let state: State
    let action: () -> Void

    init(activity: ActivityType, state: ActivityPreferencesStepView.ChipState, action: @escaping () -> Void) {
        self.activity = activity
        switch state {
        case .preferred: self.state = .preferred
        case .disliked:  self.state = .disliked
        case .neutral:   self.state = .neutral
        }
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: activity.icon)
                    .font(.title3)
                    .foregroundStyle(chipIconColor)

                Text(activity.displayName)
                    .font(.caption2.weight(state == .neutral ? .regular : .semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(state == .neutral ? .secondary : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(chipBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(chipBorder, lineWidth: 1.5)
            )
            .animation(.spring(duration: 0.25), value: state == .neutral)
        }
        .buttonStyle(.plain)
    }

    private var chipBackground: Color {
        switch state {
        case .preferred: return Color.fgGreen.opacity(0.12)
        case .disliked:  return Color.fgOrange.opacity(0.12)
        case .neutral:   return Color.secondary.opacity(0.08)
        }
    }

    private var chipIconColor: Color {
        switch state {
        case .preferred: return Color.fgGreen
        case .disliked:  return Color.fgOrange
        case .neutral:   return Color.secondary
        }
    }

    private var chipBorder: Color {
        switch state {
        case .preferred: return Color.fgGreen
        case .disliked:  return Color.fgOrange
        case .neutral:   return Color.clear
        }
    }
}

#Preview {
    ActivityPreferencesStepView(vm: OnboardingViewModel())
}
