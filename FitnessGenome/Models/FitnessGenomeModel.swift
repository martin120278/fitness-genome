// FitnessGenomeModel.swift
// FitnessGenome
// El "ADN fitness" único por usuario — vector multidimensional que evoluciona con el tiempo

import Foundation
import SwiftData

/// El Fitness Genome es un perfil vectorial normalizado (0-1) que representa
/// las tendencias, capacidades y preferencias del usuario en cada dimensión de fitness.
/// Se actualiza tras cada sesión registrada.
@Model
final class FitnessGenomeModel {

    var id: UUID
    var userId: UUID
    var lastUpdated: Date
    var version: Int                    // Incrementa con cada actualización

    // MARK: - Dimensiones de capacidad (0.0 - 1.0)
    var strengthScore: Double           // Fuerza muscular
    var enduranceScore: Double          // Resistencia cardiovascular
    var mobilityScore: Double           // Flexibilidad y movilidad
    var balanceScore: Double            // Equilibrio y coordinación
    var recoveryScore: Double           // Capacidad de recuperación

    // MARK: - Dimensiones de preferencia (0.0 - 1.0)
    var preferenceStrength: Double      // Afinidad con ejercicios de fuerza
    var preferenceCardio: Double        // Afinidad con cardio
    var preferenceMindBody: Double      // Afinidad con yoga/pilates/movilidad
    var preferenceTeam: Double          // Afinidad con deportes recreativos/grupales

    // MARK: - Dimensiones de comportamiento
    var consistencyScore: Double        // Adherencia al plan (0-1)
    var adaptationRate: Double          // Qué tan rápido progresa (0-1)
    var fatigueResistance: Double       // Tolerancia al volumen de entrenamiento

    // MARK: - Historial de puntuaciones (para gráficos de evolución)
    // Guardado como JSON string por compatibilidad con SwiftData
    private var _scoreHistoryJSON: String

    var scoreHistory: [GenomeSnapshot] {
        get {
            guard let data = _scoreHistoryJSON.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([GenomeSnapshot].self, from: data)
            else { return [] }
            return decoded
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let str = String(data: data, encoding: .utf8) {
                _scoreHistoryJSON = str
            }
        }
    }

    init(userId: UUID) {
        self.id = UUID()
        self.userId = userId
        self.lastUpdated = Date()
        self.version = 1

        // Valores iniciales basados en perfil del usuario (se refinan en onboarding)
        self.strengthScore = 0.3
        self.enduranceScore = 0.3
        self.mobilityScore = 0.3
        self.balanceScore = 0.3
        self.recoveryScore = 0.5

        self.preferenceStrength = 0.5
        self.preferenceCardio = 0.5
        self.preferenceMindBody = 0.5
        self.preferenceTeam = 0.3

        self.consistencyScore = 0.5
        self.adaptationRate = 0.5
        self.fatigueResistance = 0.5

        self._scoreHistoryJSON = "[]"
    }

    // MARK: - Métodos de actualización

    /// Calibra el genome inicial basado en el perfil del usuario
    func calibrateFromProfile(_ profile: UserProfile) {
        let levelFactor = Double(profile.overallFitnessLevel.numericValue) / 4.0

        strengthScore = levelFactor * 0.7 + (profile.experience(for: .weightTraining).numericFactor * 0.3)
        enduranceScore = levelFactor * 0.7 + (profile.experience(for: .running).numericFactor * 0.3)
        mobilityScore = levelFactor * 0.5 + (profile.experience(for: .yoga).numericFactor * 0.5)
        balanceScore = levelFactor * 0.6

        // Ajustar por sueño y estrés
        let sleepFactor = min(profile.averageSleepHours / 8.0, 1.0)
        let stressFactor = 1.0 - (Double(profile.stressLevel.numericValue) / 4.0)
        recoveryScore = (sleepFactor * 0.6) + (stressFactor * 0.4)

        // Preferencias desde actividades preferidas
        for activityRaw in profile.preferredActivities {
            guard let activity = ActivityType(rawValue: activityRaw) else { continue }
            switch activity.category {
            case .strength:     preferenceStrength = min(preferenceStrength + 0.2, 1.0)
            case .cardio:       preferenceCardio = min(preferenceCardio + 0.2, 1.0)
            case .mindBody:     preferenceMindBody = min(preferenceMindBody + 0.2, 1.0)
            case .recreational: preferenceTeam = min(preferenceTeam + 0.2, 1.0)
            }
        }

        saveSnapshot()
        version += 1
        lastUpdated = Date()
    }

    private func saveSnapshot() {
        let snapshot = GenomeSnapshot(
            date: Date(),
            version: version,
            strength: strengthScore,
            endurance: enduranceScore,
            mobility: mobilityScore,
            recovery: recoveryScore
        )
        var history = scoreHistory
        history.append(snapshot)
        // Mantener solo los últimos 52 snapshots (1 año semanal aprox.)
        if history.count > 52 { history.removeFirst() }
        scoreHistory = history
    }
}

// MARK: - Snapshot para historial

struct GenomeSnapshot: Codable {
    let date: Date
    let version: Int
    let strength: Double
    let endurance: Double
    let mobility: Double
    let recovery: Double
}

// MARK: - Extensiones de conveniencia

extension FitnessLevel {
    var numericValue: Int {
        switch self {
        case .sedentary:    return 0
        case .beginner:     return 1
        case .intermediate: return 2
        case .advanced:     return 3
        case .athlete:      return 4
        }
    }
}

extension ExperienceLevel {
    var numericFactor: Double {
        switch self {
        case .none:         return 0.0
        case .beginner:     return 0.3
        case .intermediate: return 0.6
        case .advanced:     return 1.0
        }
    }
}

extension StressLevel {
    var numericValue: Int {
        switch self {
        case .low:      return 0
        case .moderate: return 1
        case .high:     return 2
        case .veryHigh: return 3
        }
    }
}
