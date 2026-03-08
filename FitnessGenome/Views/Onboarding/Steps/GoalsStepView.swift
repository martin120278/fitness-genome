// GoalsStepView.swift
// FitnessGenome
// Paso 5: Objetivos de fitness

import SwiftUI

struct GoalsStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                stepHeader
                    .fadeInOnAppear(delay: 0.0)

                // Objetivo principal
                primaryGoalSection
                    .fadeInOnAppear(delay: 0.1)

                // Objetivos secundarios
                secondaryGoalsSection
                    .fadeInOnAppear(delay: 0.25)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    // MARK: - Header

    private var stepHeader: some View {
        VStack(spacing: 6) {
            Text("¿Qué quieres lograr?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Elige tu objetivo principal y, si quieres,\nagregar objetivos secundarios.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Objetivo principal

    private var primaryGoalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Objetivo principal")
                .font(.subheadline.weight(.semibold))

            ForEach(FitnessGoal.allCases) { goal in
                OptionCard(
                    title: goal.displayName,
                    subtitle: goalDescription(goal),
                    icon: goal.icon,
                    isSelected: vm.primaryGoal == goal
                ) {
                    withAnimation(.spring(duration: 0.3)) {
                        vm.primaryGoal = goal
                        // Si el primario está en secundarios, quitarlo
                        vm.selectedSecondaryGoals.remove(goal)
                    }
                }
            }
        }
    }

    // MARK: - Objetivos secundarios

    private var secondaryGoalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Objetivos secundarios (opcional)")
                .font(.subheadline.weight(.semibold))

            Text("Selecciona todos los que apliquen")
                .font(.caption)
                .foregroundStyle(.secondary)

            let secondaryOptions = FitnessGoal.allCases.filter { $0 != vm.primaryGoal }

            FlowLayout(spacing: 8) {
                ForEach(secondaryOptions) { goal in
                    SelectionChip(
                        title: goal.displayName,
                        icon: goal.icon,
                        isSelected: vm.selectedSecondaryGoals.contains(goal)
                    ) {
                        withAnimation(.spring(duration: 0.25)) {
                            if vm.selectedSecondaryGoals.contains(goal) {
                                vm.selectedSecondaryGoals.remove(goal)
                            } else {
                                vm.selectedSecondaryGoals.insert(goal)
                            }
                        }
                    }
                }
            }
        }
    }

    private func goalDescription(_ goal: FitnessGoal) -> String {
        switch goal {
        case .weightLoss:         return "Reducir grasa corporal de forma sostenible"
        case .muscleGain:         return "Aumentar masa muscular y fuerza"
        case .endurance:          return "Mejorar capacidad cardiovascular"
        case .flexibility:        return "Mayor rango de movimiento y bienestar"
        case .generalFitness:     return "Estar en buena forma y salud general"
        case .stressRelief:       return "Usar el ejercicio para manejar el estrés"
        case .sportsPerformance:  return "Mejorar rendimiento en un deporte"
        case .rehabilitation:     return "Recuperación de lesión o cirugía"
        case .weightMaintenance:  return "Mantener el peso actual de forma activa"
        }
    }
}

// MARK: - FlowLayout (chips que fluyen en múltiples líneas)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.size.height }.max() ?? 0 }.reduce(0) { $0 + $1 + spacing }
        return CGSize(width: proposal.width ?? 0, height: max(0, height - spacing))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.size.height }.max() ?? 0
            for item in row {
                item.view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(item.size))
                x += item.size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[RowItem]] {
        let maxWidth = proposal.width ?? 0
        var rows: [[RowItem]] = [[]]
        var currentWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentWidth + size.width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                currentWidth = 0
            }
            rows[rows.count - 1].append(RowItem(view: subview, size: size))
            currentWidth += size.width + spacing
        }
        return rows
    }

    private struct RowItem {
        let view: LayoutSubview
        let size: CGSize
    }
}

#Preview {
    GoalsStepView(vm: OnboardingViewModel())
}
