// SessionLog.swift
// FitnessGenome
// Registro de sesión completada + feedback del usuario

import Foundation
import SwiftData

@Model
final class SessionLog {

    var id: UUID
    var userId: UUID
    var plannedSessionId: UUID?         // nil si es sesión libre no planificada
    var date: Date
    var activityType: String            // ActivityType.rawValue
    var durationMinutes: Int
    var intensityActual: String         // SessionIntensity.rawValue

    // MARK: - Métricas HealthKit (opcionales)
    var heartRateAvg: Double?
    var heartRateMax: Double?
    var caloriesBurned: Double?
    var distanceKm: Double?
    var steps: Int?

    // MARK: - Feedback subjetivo (1-10)
    var energyBefore: Int               // ¿Cómo llegué?
    var energyAfter: Int                // ¿Cómo me siento después?
    var perceivedDifficulty: Int        // RPE subjetivo
    var satisfaction: Int               // Satisfacción con la sesión
    var muscleSoreness: Int             // Dolor/agujetas (1=nada, 10=mucho)

    // MARK: - Notas adicionales
    var notes: String
    var painPoints: [String]            // InjuryType.rawValues mencionados

    // MARK: - Estado del genome al registrar
    var genomeVersionAtLog: Int

    init(
        userId: UUID,
        activityType: ActivityType,
        durationMinutes: Int,
        intensity: SessionIntensity
    ) {
        self.id = UUID()
        self.userId = userId
        self.plannedSessionId = nil
        self.date = Date()
        self.activityType = activityType.rawValue
        self.durationMinutes = durationMinutes
        self.intensityActual = intensity.rawValue
        self.energyBefore = 5
        self.energyAfter = 5
        self.perceivedDifficulty = 5
        self.satisfaction = 5
        self.muscleSoreness = 3
        self.notes = ""
        self.painPoints = []
        self.genomeVersionAtLog = 1
    }

    var activity: ActivityType? {
        ActivityType(rawValue: activityType)
    }

    var intensity: SessionIntensity? {
        SessionIntensity(rawValue: intensityActual)
    }

    /// Score compuesto para el algoritmo de actualización del genome
    var qualityScore: Double {
        // Ponderación: satisfacción 40%, energía post 30%, dificultad apropiada 30%
        let satisfactionNorm = Double(satisfaction) / 10.0
        let energyNorm = Double(energyAfter) / 10.0
        // Dificultad óptima ~6-7/10 — penaliza extremos
        let diffOptimal = 1.0 - abs(Double(perceivedDifficulty) - 6.5) / 5.0
        return (satisfactionNorm * 0.4) + (energyNorm * 0.3) + (max(0, diffOptimal) * 0.3)
    }
}
