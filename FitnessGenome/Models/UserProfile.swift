// UserProfile.swift
// FitnessGenome
// Modelo principal del usuario — persistido con SwiftData

import Foundation
import SwiftData

@Model
final class UserProfile {

    // MARK: - Identidad
    var id: UUID
    var name: String
    var createdAt: Date

    // MARK: - Datos físicos
    var age: Int
    var sex: BiologicalSex
    var heightCm: Double
    var weightKg: Double

    // MARK: - Nivel general
    var overallFitnessLevel: FitnessLevel

    // MARK: - Lesiones / limitaciones
    var injuries: [InjuryType]
    var injuryNotes: String

    // MARK: - Objetivos
    var primaryGoal: FitnessGoal
    var secondaryGoals: [FitnessGoal]

    // MARK: - Disponibilidad
    var availableDaysPerWeek: Int          // 2-7
    var sessionDurationMinutes: Int        // 30-120

    // MARK: - Equipamiento
    var availableEquipment: [EquipmentType]

    // MARK: - Sueño y estrés
    var averageSleepHours: Double          // 4-10
    var stressLevel: StressLevel

    // MARK: - Experiencia por disciplina (ActivityType.rawValue -> ExperienceLevel.rawValue)
    var disciplineExperience: [String: Int]

    // MARK: - Preferencias de actividad
    var preferredActivities: [String]      // ActivityType rawValues
    var dislikedActivities: [String]       // ActivityType rawValues

    // MARK: - Estado de onboarding
    var hasCompletedOnboarding: Bool

    // MARK: - Init
    init() {
        self.id = UUID()
        self.name = ""
        self.createdAt = Date()
        self.age = 30
        self.sex = .notSpecified
        self.heightCm = 170
        self.weightKg = 70
        self.overallFitnessLevel = .beginner
        self.injuries = []
        self.injuryNotes = ""
        self.primaryGoal = .generalFitness
        self.secondaryGoals = []
        self.availableDaysPerWeek = 3
        self.sessionDurationMinutes = 60
        self.availableEquipment = [.bodyweight]
        self.averageSleepHours = 7
        self.stressLevel = .moderate
        self.disciplineExperience = [:]
        self.preferredActivities = []
        self.dislikedActivities = []
        self.hasCompletedOnboarding = false
    }

    /// BMI calculado
    var bmi: Double {
        guard heightCm > 0 else { return 0 }
        let heightM = heightCm / 100
        return weightKg / (heightM * heightM)
    }

    /// Experiencia en una disciplina
    func experience(for activity: ActivityType) -> ExperienceLevel {
        let raw = disciplineExperience[activity.rawValue] ?? 0
        return ExperienceLevel(rawValue: raw) ?? .none
    }

    func setExperience(_ level: ExperienceLevel, for activity: ActivityType) {
        disciplineExperience[activity.rawValue] = level.rawValue
    }
}

// MARK: - Enums de apoyo

enum BiologicalSex: String, Codable, CaseIterable {
    case male        = "male"
    case female      = "female"
    case notSpecified = "not_specified"

    var displayName: String {
        switch self {
        case .male:         return "Masculino"
        case .female:       return "Femenino"
        case .notSpecified: return "Prefiero no indicar"
        }
    }
}

enum FitnessLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary   = "sedentary"
    case beginner    = "beginner"
    case intermediate = "intermediate"
    case advanced    = "advanced"
    case athlete     = "athlete"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sedentary:    return "Sedentario"
        case .beginner:     return "Principiante"
        case .intermediate: return "Intermedio"
        case .advanced:     return "Avanzado"
        case .athlete:      return "Atleta"
        }
    }

    var description: String {
        switch self {
        case .sedentary:    return "Actualmente no hago ejercicio regular"
        case .beginner:     return "Ejercicio ocasional, menos de 6 meses"
        case .intermediate: return "Ejercicio regular, 1-3 años"
        case .advanced:     return "Entrenamiento consistente, 3+ años"
        case .athlete:      return "Competición o entrenamiento de alto nivel"
        }
    }
}

enum FitnessGoal: String, Codable, CaseIterable, Identifiable {
    case weightLoss      = "weight_loss"
    case muscleGain      = "muscle_gain"
    case endurance       = "endurance"
    case flexibility     = "flexibility"
    case generalFitness  = "general_fitness"
    case stressRelief    = "stress_relief"
    case sportsPerformance = "sports_performance"
    case rehabilitation  = "rehabilitation"
    case weightMaintenance = "weight_maintenance"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weightLoss:        return "Perder peso"
        case .muscleGain:        return "Ganar músculo"
        case .endurance:         return "Mejorar resistencia"
        case .flexibility:       return "Aumentar flexibilidad"
        case .generalFitness:    return "Fitness general"
        case .stressRelief:      return "Reducir estrés"
        case .sportsPerformance: return "Rendimiento deportivo"
        case .rehabilitation:    return "Rehabilitación"
        case .weightMaintenance: return "Mantener peso"
        }
    }

    var icon: String {
        switch self {
        case .weightLoss:        return "arrow.down.circle.fill"
        case .muscleGain:        return "bolt.fill"
        case .endurance:         return "heart.fill"
        case .flexibility:       return "figure.flexibility"
        case .generalFitness:    return "star.fill"
        case .stressRelief:      return "leaf.fill"
        case .sportsPerformance: return "trophy.fill"
        case .rehabilitation:    return "cross.fill"
        case .weightMaintenance: return "equal.circle.fill"
        }
    }
}

enum InjuryType: String, Codable, CaseIterable, Identifiable {
    case none           = "none"
    case lowerBack      = "lower_back"
    case knee           = "knee"
    case shoulder       = "shoulder"
    case hip            = "hip"
    case ankle          = "ankle"
    case wrist          = "wrist"
    case neck           = "neck"
    case elbow          = "elbow"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none:      return "Sin lesiones"
        case .lowerBack: return "Lumbar / Espalda baja"
        case .knee:      return "Rodilla"
        case .shoulder:  return "Hombro"
        case .hip:       return "Cadera"
        case .ankle:     return "Tobillo"
        case .wrist:     return "Muñeca"
        case .neck:      return "Cuello / Cervical"
        case .elbow:     return "Codo"
        }
    }
}

enum EquipmentType: String, Codable, CaseIterable, Identifiable {
    case bodyweight   = "bodyweight"
    case dumbbells    = "dumbbells"
    case barbell      = "barbell"
    case pullupBar    = "pullup_bar"
    case resistanceBands = "resistance_bands"
    case kettlebell   = "kettlebell"
    case gym          = "gym"
    case pool         = "pool"
    case bike         = "bike"
    case treadmill    = "treadmill"
    case yogaMat      = "yoga_mat"
    case trx          = "trx"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bodyweight:       return "Solo peso corporal"
        case .dumbbells:        return "Mancuernas"
        case .barbell:          return "Barra + pesos"
        case .pullupBar:        return "Barra de dominadas"
        case .resistanceBands:  return "Bandas elásticas"
        case .kettlebell:       return "Kettlebell"
        case .gym:              return "Gimnasio completo"
        case .pool:             return "Piscina"
        case .bike:             return "Bicicleta"
        case .treadmill:        return "Cinta de correr"
        case .yogaMat:          return "Esterilla de yoga"
        case .trx:              return "TRX / Suspensión"
        }
    }

    var icon: String {
        switch self {
        case .bodyweight:       return "figure.strengthtraining.functional"
        case .dumbbells:        return "dumbbell.fill"
        case .barbell:          return "dumbbell.fill"
        case .pullupBar:        return "arrow.up.circle.fill"
        case .resistanceBands:  return "link.circle.fill"
        case .kettlebell:       return "circle.fill"
        case .gym:              return "building.2.fill"
        case .pool:             return "drop.fill"
        case .bike:             return "bicycle"
        case .treadmill:        return "figure.run"
        case .yogaMat:          return "rectangle.fill"
        case .trx:              return "line.diagonal"
        }
    }
}

enum StressLevel: String, Codable, CaseIterable, Identifiable {
    case low      = "low"
    case moderate = "moderate"
    case high     = "high"
    case veryHigh = "very_high"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low:      return "Bajo"
        case .moderate: return "Moderado"
        case .high:     return "Alto"
        case .veryHigh: return "Muy alto"
        }
    }

    var description: String {
        switch self {
        case .low:      return "Me siento relajado la mayor parte del tiempo"
        case .moderate: return "Estrés normal del día a día"
        case .high:     return "Bastante estresado, afecta mi vida"
        case .veryHigh: return "Muy estresado, me cuesta recuperarme"
        }
    }
}
