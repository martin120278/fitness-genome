// WeeklyPlan.swift
// FitnessGenome
// Plan semanal generado por el motor de recomendación

import Foundation
import SwiftData

@Model
final class WeeklyPlan {

    var id: UUID
    var userId: UUID
    var weekStartDate: Date
    var weekNumber: Int             // Número de semana dentro del programa
    var genomeVersion: Int          // Versión del genome al generar el plan
    var isActive: Bool

    // Sesiones planificadas (almacenadas como JSON)
    private var _sessionsJSON: String
    var sessions: [PlannedSession] {
        get {
            guard let data = _sessionsJSON.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([PlannedSession].self, from: data)
            else { return [] }
            return decoded
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let str = String(data: data, encoding: .utf8) {
                _sessionsJSON = str
            }
        }
    }

    // Métricas del plan
    var totalVolume: PlanVolume       // Distribución de cargas
    var planNotes: String             // Insights del plan

    init(userId: UUID, weekStartDate: Date, weekNumber: Int, genomeVersion: Int) {
        self.id = UUID()
        self.userId = userId
        self.weekStartDate = weekStartDate
        self.weekNumber = weekNumber
        self.genomeVersion = genomeVersion
        self.isActive = true
        self._sessionsJSON = "[]"
        self.totalVolume = PlanVolume()
        self.planNotes = ""
    }

    var completedSessions: Int {
        sessions.filter { $0.isCompleted }.count
    }

    var completionPercentage: Double {
        guard !sessions.isEmpty else { return 0 }
        return Double(completedSessions) / Double(sessions.count)
    }
}

// MARK: - Sesión planificada

struct PlannedSession: Codable, Identifiable {
    var id: UUID
    var dayOfWeek: Int              // 1=Lunes, 7=Domingo
    var activityType: String        // ActivityType.rawValue
    var durationMinutes: Int
    var intensity: SessionIntensity
    var focus: String               // Descripción del enfoque
    var exercises: [ExercisePlan]   // Ejercicios sugeridos
    var isCompleted: Bool
    var completedLogId: UUID?       // Referencia al SessionLog completado

    init(
        dayOfWeek: Int,
        activityType: ActivityType,
        durationMinutes: Int,
        intensity: SessionIntensity,
        focus: String,
        exercises: [ExercisePlan] = []
    ) {
        self.id = UUID()
        self.dayOfWeek = dayOfWeek
        self.activityType = activityType.rawValue
        self.durationMinutes = durationMinutes
        self.intensity = intensity
        self.focus = focus
        self.exercises = exercises
        self.isCompleted = false
        self.completedLogId = nil
    }

    var activity: ActivityType? {
        ActivityType(rawValue: activityType)
    }

    var dayName: String {
        let days = ["", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
        guard dayOfWeek >= 1 && dayOfWeek <= 7 else { return "Día \(dayOfWeek)" }
        return days[dayOfWeek]
    }
}

struct ExercisePlan: Codable, Identifiable {
    var id: UUID
    var name: String
    var sets: Int?
    var reps: String?               // "8-12" o "AMRAP" etc.
    var durationSeconds: Int?
    var restSeconds: Int
    var notes: String

    init(name: String, sets: Int? = nil, reps: String? = nil, durationSeconds: Int? = nil, restSeconds: Int = 60, notes: String = "") {
        self.id = UUID()
        self.name = name
        self.sets = sets
        self.reps = reps
        self.durationSeconds = durationSeconds
        self.restSeconds = restSeconds
        self.notes = notes
    }
}

enum SessionIntensity: String, Codable, CaseIterable {
    case recovery  = "recovery"
    case light     = "light"
    case moderate  = "moderate"
    case hard      = "hard"
    case maxEffort = "max_effort"

    var displayName: String {
        switch self {
        case .recovery:  return "Recuperación"
        case .light:     return "Suave"
        case .moderate:  return "Moderada"
        case .hard:      return "Intensa"
        case .maxEffort: return "Máximo esfuerzo"
        }
    }

    var color: String {
        switch self {
        case .recovery:  return "blue"
        case .light:     return "green"
        case .moderate:  return "yellow"
        case .hard:      return "orange"
        case .maxEffort: return "red"
        }
    }

    var rpeFactor: Double {
        switch self {
        case .recovery:  return 0.4
        case .light:     return 0.55
        case .moderate:  return 0.7
        case .hard:      return 0.85
        case .maxEffort: return 0.95
        }
    }
}

struct PlanVolume: Codable {
    var strengthMinutes: Int = 0
    var cardioMinutes: Int = 0
    var mindBodyMinutes: Int = 0
    var recoveryMinutes: Int = 0

    var total: Int { strengthMinutes + cardioMinutes + mindBodyMinutes + recoveryMinutes }
}
