// ActivityType.swift
// FitnessGenome
// Enum que define todos los tipos de actividad física soportados

import Foundation

enum ActivityType: String, Codable, CaseIterable, Identifiable {
    // Fuerza
    case weightTraining = "weight_training"
    case calisthenics = "calisthenics"

    // Cardio
    case running = "running"
    case cycling = "cycling"
    case swimming = "swimming"
    case walking = "walking"
    case hiit = "hiit"

    // Mente-cuerpo
    case yoga = "yoga"
    case pilates = "pilates"
    case mobility = "mobility"

    // Recreativo
    case recreationalSports = "recreational_sports"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weightTraining:    return "Musculación"
        case .calisthenics:      return "Calistenia"
        case .running:           return "Running"
        case .cycling:           return "Ciclismo"
        case .swimming:          return "Natación"
        case .walking:           return "Caminata"
        case .hiit:              return "HIIT"
        case .yoga:              return "Yoga"
        case .pilates:           return "Pilates"
        case .mobility:          return "Movilidad"
        case .recreationalSports: return "Deportes Rec."
        }
    }

    var icon: String {
        switch self {
        case .weightTraining:    return "dumbbell.fill"
        case .calisthenics:      return "figure.strengthtraining.functional"
        case .running:           return "figure.run"
        case .cycling:           return "figure.outdoor.cycle"
        case .swimming:          return "figure.pool.swim"
        case .walking:           return "figure.walk"
        case .hiit:              return "bolt.heart.fill"
        case .yoga:              return "figure.yoga"
        case .pilates:           return "figure.pilates"
        case .mobility:          return "figure.flexibility"
        case .recreationalSports: return "sportscourt.fill"
        }
    }

    /// Categoría de fitness principal
    var category: ActivityCategory {
        switch self {
        case .weightTraining, .calisthenics:
            return .strength
        case .running, .cycling, .swimming, .walking, .hiit:
            return .cardio
        case .yoga, .pilates, .mobility:
            return .mindBody
        case .recreationalSports:
            return .recreational
        }
    }

    /// Nivel de impacto articular (1=bajo, 3=alto)
    var jointImpact: Int {
        switch self {
        case .running, .hiit:                    return 3
        case .weightTraining, .calisthenics:     return 2
        case .cycling, .swimming, .yoga,
             .pilates, .mobility:                return 1
        case .walking:                           return 1
        case .recreationalSports:                return 2
        }
    }
}

enum ActivityCategory: String, Codable, CaseIterable {
    case strength      = "strength"
    case cardio        = "cardio"
    case mindBody      = "mind_body"
    case recreational  = "recreational"

    var displayName: String {
        switch self {
        case .strength:     return "Fuerza"
        case .cardio:       return "Cardio"
        case .mindBody:     return "Mente-Cuerpo"
        case .recreational: return "Recreativo"
        }
    }
}

/// Nivel de experiencia del usuario en una disciplina
enum ExperienceLevel: Int, Codable, CaseIterable, Identifiable {
    case none        = 0
    case beginner    = 1
    case intermediate = 2
    case advanced    = 3

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .none:         return "Sin experiencia"
        case .beginner:     return "Principiante"
        case .intermediate: return "Intermedio"
        case .advanced:     return "Avanzado"
        }
    }

    var shortName: String {
        switch self {
        case .none:         return "Ninguno"
        case .beginner:     return "Básico"
        case .intermediate: return "Medio"
        case .advanced:     return "Avanzado"
        }
    }
}
