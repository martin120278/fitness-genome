// HomeViewModel.swift
// FitnessGenome
// ViewModel que gestiona la pantalla principal: carga o genera el plan semanal activo

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class HomeViewModel {

    var currentPlan: WeeklyPlan? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // MARK: - Carga o generación del plan

    func loadOrGeneratePlan(
        profile: UserProfile,
        genome: FitnessGenomeModel,
        context: ModelContext
    ) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let userId = profile.id
            let descriptor = FetchDescriptor<WeeklyPlan>(
                predicate: #Predicate { $0.userId == userId && $0.isActive == true },
                sortBy: [SortDescriptor(\.weekStartDate, order: .reverse)]
            )
            let existingPlans = try context.fetch(descriptor)
            let weekStart = currentWeekStart()

            // Reutilizar plan si ya existe para esta semana
            if let plan = existingPlans.first(where: {
                Calendar.current.isDate($0.weekStartDate, equalTo: weekStart, toGranularity: .weekOfYear)
            }) {
                currentPlan = plan
                return
            }

            // Generar nuevo plan
            let weekNumber = Calendar.current.component(.weekOfYear, from: Date())
            let generator = WeeklyPlanGenerator()
            let newPlan = generator.generate(
                profile: profile,
                genome: genome,
                weekNumber: weekNumber
            )
            context.insert(newPlan)
            try context.save()
            currentPlan = newPlan

        } catch {
            errorMessage = "No se pudo cargar el plan: \(error.localizedDescription)"
        }
    }

    // MARK: - Helper

    private func currentWeekStart() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return calendar.date(from: comps) ?? Date()
    }
}
