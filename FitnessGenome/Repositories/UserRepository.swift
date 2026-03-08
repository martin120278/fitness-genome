// UserRepository.swift
// FitnessGenome
// Repositorio para acceso a UserProfile y FitnessGenomeModel en SwiftData

import Foundation
import SwiftData

@MainActor
final class UserRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - UserProfile

    func fetchCurrentUser() throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).first
    }

    func hasCompletedOnboarding() -> Bool {
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { $0.hasCompletedOnboarding == true }
        )
        return (try? context.fetch(descriptor))?.isEmpty == false
    }

    func updateProfile(_ profile: UserProfile) throws {
        try context.save()
    }

    // MARK: - FitnessGenome

    func fetchGenome(for userId: UUID) throws -> FitnessGenomeModel? {
        let descriptor = FetchDescriptor<FitnessGenomeModel>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)]
        )
        return try context.fetch(descriptor).first
    }

    func saveGenome(_ genome: FitnessGenomeModel) throws {
        context.insert(genome)
        try context.save()
    }

    // MARK: - SessionLog

    func fetchRecentSessions(userId: UUID, limit: Int = 20) throws -> [SessionLog] {
        var descriptor = FetchDescriptor<SessionLog>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    func saveSession(_ session: SessionLog) throws {
        context.insert(session)
        try context.save()
    }

    // MARK: - WeeklyPlan

    func fetchActiveWeeklyPlan(userId: UUID) throws -> WeeklyPlan? {
        let descriptor = FetchDescriptor<WeeklyPlan>(
            predicate: #Predicate { $0.userId == userId && $0.isActive == true },
            sortBy: [SortDescriptor(\.weekStartDate, order: .reverse)]
        )
        return try context.fetch(descriptor).first
    }

    func saveWeeklyPlan(_ plan: WeeklyPlan) throws {
        context.insert(plan)
        try context.save()
    }
}
