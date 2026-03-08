// WeeklyPlanGenerator.swift
// FitnessGenome
// Servicio que genera el plan semanal inteligente — mesociclo de 4 semanas

import Foundation

@MainActor
struct WeeklyPlanGenerator {

    // MARK: - Fase del mesociclo (4 semanas cíclicas)

    private enum MesocyclePhase: Equatable {
        case adaptation   // Semana 1 — ajuste al volumen, técnica
        case build        // Semana 2 — acumulación progresiva
        case peak         // Semana 3 — intensificación
        case deload       // Semana 4 — descarga y recuperación

        static func from(weekNumber: Int) -> MesocyclePhase {
            switch weekNumber % 4 {
            case 1:  return .adaptation
            case 2:  return .build
            case 3:  return .peak
            default: return .deload
            }
        }

        var intensityTarget: SessionIntensity {
            switch self {
            case .adaptation: return .light
            case .build:      return .moderate
            case .peak:       return .hard
            case .deload:     return .recovery
            }
        }

        var durationFactor: Double {
            switch self {
            case .adaptation: return 0.80
            case .build:      return 0.90
            case .peak:       return 1.00
            case .deload:     return 0.65
            }
        }

        var displayName: String {
            switch self {
            case .adaptation: return "Adaptación"
            case .build:      return "Acumulación"
            case .peak:       return "Intensificación"
            case .deload:     return "Descarga"
            }
        }
    }

    // MARK: - Punto de entrada principal

    func generate(
        profile: UserProfile,
        genome: FitnessGenomeModel,
        weekNumber: Int,
        startingFrom startDate: Date = Date()
    ) -> WeeklyPlan {
        let phase = MesocyclePhase.from(weekNumber: weekNumber)
        let plan = WeeklyPlan(
            userId: profile.id,
            weekStartDate: startOfWeek(from: startDate),
            weekNumber: weekNumber,
            genomeVersion: genome.version
        )
        let sessions = buildSessions(profile: profile, genome: genome, phase: phase)
        plan.sessions = sessions
        plan.totalVolume = computeVolume(sessions: sessions)
        plan.planNotes = buildNotes(profile: profile, genome: genome, phase: phase)
        return plan
    }

    // MARK: - Construcción de sesiones

    private func buildSessions(
        profile: UserProfile,
        genome: FitnessGenomeModel,
        phase: MesocyclePhase
    ) -> [PlannedSession] {
        let days = trainingDays(for: profile.availableDaysPerWeek)
        let ranked = rankActivities(profile: profile, genome: genome)
        let baseDuration = Int(Double(profile.sessionDurationMinutes) * phase.durationFactor)
        var sessions: [PlannedSession] = []
        var usedActivities: [ActivityType] = []

        for (slotIndex, dayOfWeek) in days.enumerated() {
            let activity = pickActivity(
                ranked: ranked,
                used: usedActivities,
                slotIndex: slotIndex,
                totalSlots: days.count,
                phase: phase
            )
            usedActivities.append(activity)

            let intensity = sessionIntensity(
                slotIndex: slotIndex,
                totalSlots: days.count,
                phase: phase,
                activity: activity
            )
            let duration = adjustedDuration(base: baseDuration, intensity: intensity)
            let exercises = buildExercises(
                activity: activity,
                intensity: intensity,
                profile: profile
            )

            sessions.append(PlannedSession(
                dayOfWeek: dayOfWeek,
                activityType: activity,
                durationMinutes: duration,
                intensity: intensity,
                focus: focusLabel(activity: activity, intensity: intensity, phase: phase),
                exercises: exercises
            ))
        }
        return sessions
    }

    // MARK: - Distribución de días (1=Lun … 7=Dom)

    private func trainingDays(for count: Int) -> [Int] {
        switch max(1, min(count, 7)) {
        case 1:  return [1]
        case 2:  return [1, 4]
        case 3:  return [1, 3, 5]
        case 4:  return [1, 2, 4, 5]
        case 5:  return [1, 2, 3, 5, 6]
        case 6:  return [1, 2, 3, 4, 5, 6]
        default: return [1, 2, 3, 4, 5, 6, 7]
        }
    }

    // MARK: - Ranking de actividades

    private func rankActivities(
        profile: UserProfile,
        genome: FitnessGenomeModel
    ) -> [ActivityType] {
        let preferred = Set(profile.preferredActivities.compactMap { ActivityType(rawValue: $0) })
        let disliked  = Set(profile.dislikedActivities.compactMap { ActivityType(rawValue: $0) })

        let scored: [(ActivityType, Double)] = ActivityType.allCases
            .filter { isAvailable($0, for: profile) }
            .map { activity in
                var score = genomeScore(activity, genome: genome)
                score += goalScore(activity, goal: profile.primaryGoal)
                if preferred.contains(activity) { score += 0.40 }
                if disliked.contains(activity)  { score -= 0.60 }
                return (activity, score)
            }
            .sorted { $0.1 > $1.1 }

        let result = scored.map { $0.0 }
        return result.isEmpty ? [.walking] : result
    }

    /// ¿Puede el usuario realizar esta actividad con su equipamiento y sin restricción por lesión total?
    private func isAvailable(_ activity: ActivityType, for profile: UserProfile) -> Bool {
        let equipment = Set(profile.availableEquipment)
        let hasGym    = equipment.contains(.gym)

        let hasEquipment: Bool
        switch activity {
        case .weightTraining:
            hasEquipment = hasGym
                || equipment.contains(.dumbbells)
                || equipment.contains(.barbell)
                || equipment.contains(.kettlebell)
        case .calisthenics:
            hasEquipment = hasGym
                || equipment.contains(.bodyweight)
                || equipment.contains(.pullupBar)
                || equipment.contains(.trx)
        case .cycling:
            hasEquipment = hasGym || equipment.contains(.bike)
        case .swimming:
            hasEquipment = equipment.contains(.pool)
        case .yoga, .pilates:
            hasEquipment = equipment.contains(.yogaMat)
                || equipment.contains(.bodyweight)
                || hasGym
        default: // running, walking, hiit, mobility, recreationalSports
            hasEquipment = true
        }

        guard hasEquipment else { return false }

        let injuries = Set(profile.injuries)
        for injury in injuries where injury != .none {
            if injuryBlocksActivity(injury, activity: activity) { return false }
        }
        return true
    }

    private func injuryBlocksActivity(_ injury: InjuryType, activity: ActivityType) -> Bool {
        switch injury {
        case .knee:     return activity == .running || activity == .hiit
        case .ankle:    return activity == .running || activity == .hiit || activity == .recreationalSports
        case .shoulder: return activity == .swimming
        case .wrist:    return activity == .calisthenics
        case .hip:      return activity == .running
        case .lowerBack, .neck, .elbow, .none: return false
        }
    }

    // MARK: - Puntuación por genome y objetivo

    private func genomeScore(_ activity: ActivityType, genome: FitnessGenomeModel) -> Double {
        switch activity.category {
        case .strength:     return genome.preferenceStrength
        case .cardio:       return genome.preferenceCardio
        case .mindBody:     return genome.preferenceMindBody
        case .recreational: return genome.preferenceTeam
        }
    }

    private func goalScore(_ activity: ActivityType, goal: FitnessGoal) -> Double {
        switch goal {
        case .muscleGain:
            switch activity {
            case .weightTraining: return 0.50
            case .calisthenics:   return 0.30
            case .hiit:           return 0.10
            default:              return 0.00
            }
        case .endurance:
            switch activity {
            case .running:        return 0.50
            case .cycling:        return 0.40
            case .swimming:       return 0.40
            case .hiit:           return 0.30
            case .walking:        return 0.20
            default:              return 0.00
            }
        case .weightLoss:
            switch activity {
            case .hiit:           return 0.50
            case .running:        return 0.40
            case .cycling:        return 0.30
            case .weightTraining: return 0.20
            case .walking:        return 0.20
            default:              return 0.00
            }
        case .flexibility:
            switch activity {
            case .yoga:           return 0.50
            case .mobility:       return 0.50
            case .pilates:        return 0.40
            default:              return 0.00
            }
        case .stressRelief:
            switch activity {
            case .yoga:           return 0.50
            case .walking:        return 0.40
            case .pilates:        return 0.30
            case .swimming:       return 0.30
            default:              return 0.00
            }
        case .sportsPerformance:
            switch activity {
            case .hiit:              return 0.40
            case .recreationalSports: return 0.40
            case .weightTraining:    return 0.30
            case .running:           return 0.30
            default:                 return 0.00
            }
        case .rehabilitation:
            switch activity {
            case .mobility:       return 0.50
            case .yoga:           return 0.40
            case .pilates:        return 0.40
            case .walking:        return 0.30
            case .swimming:       return 0.30
            default:              return -0.20
            }
        case .generalFitness, .weightMaintenance:
            return 0.05
        }
    }

    // MARK: - Selección de actividad por slot

    private func pickActivity(
        ranked: [ActivityType],
        used: [ActivityType],
        slotIndex: Int,
        totalSlots: Int,
        phase: MesocyclePhase
    ) -> ActivityType {
        // En deload o último slot (≥4 días), priorizar recuperación activa
        let isLastSlot = slotIndex == totalSlots - 1
        if phase == .deload || (isLastSlot && totalSlots >= 4) {
            let recoveryOptions: [ActivityType] = [.mobility, .yoga, .pilates, .walking]
            if let rec = recoveryOptions.first(where: { ranked.contains($0) }) {
                return rec
            }
        }

        // Mejor actividad no usada aún
        if let next = ranked.first(where: { !used.contains($0) }) {
            return next
        }
        // Rotación cuando hay pocas opciones disponibles
        return ranked[slotIndex % ranked.count]
    }

    // MARK: - Intensidad de sesión

    private func sessionIntensity(
        slotIndex: Int,
        totalSlots: Int,
        phase: MesocyclePhase,
        activity: ActivityType
    ) -> SessionIntensity {
        // Actividades mente-cuerpo: siempre suaves
        if activity.category == .mindBody {
            return phase == .deload ? .recovery : .light
        }

        let position = totalSlots > 1
            ? Double(slotIndex) / Double(totalSlots - 1)
            : 0.0

        switch phase {
        case .adaptation:
            return position < 0.5 ? .light : .moderate
        case .build:
            if position < 0.33 { return .moderate }
            if position < 0.67 { return .hard }
            return .moderate
        case .peak:
            if position < 0.25 { return .hard }
            if position < 0.50 { return .maxEffort }
            if position < 0.75 { return .hard }
            return .moderate
        case .deload:
            return .recovery
        }
    }

    private func adjustedDuration(base: Int, intensity: SessionIntensity) -> Int {
        let factor: Double
        switch intensity {
        case .recovery:  factor = 0.60
        case .light:     factor = 0.85
        case .moderate:  factor = 1.00
        case .hard:      factor = 1.10
        case .maxEffort: factor = 0.90
        }
        return max(20, Int(Double(base) * factor))
    }

    private func focusLabel(
        activity: ActivityType,
        intensity: SessionIntensity,
        phase: MesocyclePhase
    ) -> String {
        switch phase {
        case .adaptation: return "\(activity.displayName) — Aprendizaje técnico"
        case .build:      return "\(activity.displayName) — \(intensity.displayName)"
        case .peak:       return "\(activity.displayName) — Máximo rendimiento"
        case .deload:     return "\(activity.displayName) — Recuperación activa"
        }
    }

    // MARK: - Construcción de ejercicios

    private func buildExercises(
        activity: ActivityType,
        intensity: SessionIntensity,
        profile: UserProfile
    ) -> [ExercisePlan] {
        let equipment = Set(profile.availableEquipment)
        let injuries  = Set(profile.injuries)
        let hasGym    = equipment.contains(.gym)

        let count: Int
        switch intensity {
        case .recovery:  count = 3
        case .light:     count = 4
        case .moderate:  count = 5
        case .hard:      count = 6
        case .maxEffort: count = 5
        }

        let filtered = exerciseTemplates(for: activity).filter { template in
            if !template.requiredEquipment.isEmpty {
                let hasAny = hasGym
                    || template.requiredEquipment.contains(where: { equipment.contains($0) })
                if !hasAny { return false }
            }
            let hasBlockingInjury = template.excludedInjuries.contains(where: {
                injuries.contains($0) && $0 != .none
            })
            return !hasBlockingInjury
        }

        let selected = Array(filtered.prefix(count))
        return selected.map { adjustForIntensity($0, intensity: intensity) }
    }

    private func adjustForIntensity(_ t: ExerciseTemplate, intensity: SessionIntensity) -> ExercisePlan {
        let factor: Double
        switch intensity {
        case .recovery:  factor = 0.50
        case .light:     factor = 0.75
        case .moderate:  factor = 1.00
        case .hard:      factor = 1.25
        case .maxEffort: factor = 1.50
        }
        let adjustedSets = t.sets.map { max(1, Int(Double($0) * factor)) }
        return ExercisePlan(
            name: t.name,
            sets: adjustedSets,
            reps: t.reps,
            durationSeconds: t.durationSeconds,
            restSeconds: t.restSeconds,
            notes: t.notes
        )
    }

    // MARK: - Volumen total del plan

    private func computeVolume(sessions: [PlannedSession]) -> PlanVolume {
        var volume = PlanVolume()
        for session in sessions {
            guard let activity = session.activity else { continue }
            switch activity.category {
            case .strength:     volume.strengthMinutes  += session.durationMinutes
            case .cardio:       volume.cardioMinutes    += session.durationMinutes
            case .mindBody:     volume.mindBodyMinutes  += session.durationMinutes
            case .recreational: volume.cardioMinutes    += session.durationMinutes
            }
        }
        volume.recoveryMinutes = sessions.count * 5  // Estiramiento post-sesión estimado
        return volume
    }

    // MARK: - Notas e insights del plan

    private func buildNotes(
        profile: UserProfile,
        genome: FitnessGenomeModel,
        phase: MesocyclePhase
    ) -> String {
        var lines: [String] = []

        lines.append("Semana de \(phase.displayName).")

        let strongest = dominantDimension(genome)
        lines.append("Tu punto fuerte: \(strongest).")

        if profile.averageSleepHours < 6 {
            lines.append("Sueño insuficiente detectado — la intensidad se redujo para favorecer tu recuperación.")
        }

        if profile.stressLevel == .high || profile.stressLevel == .veryHigh {
            lines.append("Estrés elevado — se priorizaron actividades mente-cuerpo en el plan.")
        }

        switch profile.primaryGoal {
        case .muscleGain:
            lines.append("Para ganar músculo, aumenta la carga progresivamente cada sesión de fuerza.")
        case .weightLoss:
            lines.append("Combina el cardio del plan con un déficit calórico moderado para mejores resultados.")
        case .endurance:
            lines.append("Aumenta el volumen de cardio gradualmente (máx. 10% por semana).")
        case .flexibility:
            lines.append("La constancia diaria en movilidad supera a sesiones largas esporádicas.")
        case .stressRelief:
            lines.append("Mantén las sesiones de yoga y movilidad como prioridad esta semana.")
        default:
            break
        }

        return lines.joined(separator: " ")
    }

    private func dominantDimension(_ genome: FitnessGenomeModel) -> String {
        let dims: [(String, Double)] = [
            ("Fuerza", genome.strengthScore),
            ("Resistencia", genome.enduranceScore),
            ("Movilidad", genome.mobilityScore),
            ("Recuperación", genome.recoveryScore)
        ]
        return dims.max(by: { $0.1 < $1.1 })?.0 ?? "Equilibrio"
    }

    // MARK: - Fecha de inicio de semana (lunes)

    private func startOfWeek(from date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps) ?? date
    }

    // MARK: - Template de ejercicio (interno)

    private struct ExerciseTemplate {
        let name: String
        let sets: Int?
        let reps: String?
        let durationSeconds: Int?
        let restSeconds: Int
        let requiredEquipment: [EquipmentType]
        let excludedInjuries: [InjuryType]
        let notes: String

        init(
            name: String,
            sets: Int? = nil,
            reps: String? = nil,
            durationSeconds: Int? = nil,
            restSeconds: Int = 60,
            requiredEquipment: [EquipmentType] = [],
            excludedInjuries: [InjuryType] = [],
            notes: String = ""
        ) {
            self.name = name
            self.sets = sets
            self.reps = reps
            self.durationSeconds = durationSeconds
            self.restSeconds = restSeconds
            self.requiredEquipment = requiredEquipment
            self.excludedInjuries = excludedInjuries
            self.notes = notes
        }
    }

    // MARK: - Base de datos de ejercicios por actividad

    // swiftlint:disable function_body_length
    private func exerciseTemplates(for activity: ActivityType) -> [ExerciseTemplate] {
        switch activity {

        case .weightTraining:
            return [
                ExerciseTemplate(name: "Sentadilla con barra", sets: 4, reps: "6-8",
                    requiredEquipment: [.barbell, .gym],
                    excludedInjuries: [.knee, .lowerBack, .hip]),
                ExerciseTemplate(name: "Press de banca con barra", sets: 4, reps: "8-10",
                    requiredEquipment: [.barbell, .gym],
                    excludedInjuries: [.shoulder, .wrist, .elbow]),
                ExerciseTemplate(name: "Peso muerto", sets: 3, reps: "5-6",
                    requiredEquipment: [.barbell, .gym],
                    excludedInjuries: [.lowerBack, .knee]),
                ExerciseTemplate(name: "Press militar con mancuernas", sets: 3, reps: "10-12",
                    requiredEquipment: [.dumbbells, .gym],
                    excludedInjuries: [.shoulder, .neck, .wrist]),
                ExerciseTemplate(name: "Remo con mancuerna", sets: 3, reps: "10-12",
                    requiredEquipment: [.dumbbells, .gym],
                    excludedInjuries: [.lowerBack, .elbow]),
                ExerciseTemplate(name: "Zancadas con mancuernas", sets: 3, reps: "12 c/lado",
                    requiredEquipment: [.dumbbells, .gym],
                    excludedInjuries: [.knee, .hip, .ankle]),
                ExerciseTemplate(name: "Curl de bíceps con mancuernas", sets: 3, reps: "12-15",
                    requiredEquipment: [.dumbbells, .gym],
                    excludedInjuries: [.elbow, .wrist]),
                ExerciseTemplate(name: "Extensión de tríceps en polea", sets: 3, reps: "12-15",
                    requiredEquipment: [.gym],
                    excludedInjuries: [.elbow, .shoulder]),
                ExerciseTemplate(name: "Kettlebell swing", sets: 4, reps: "15-20",
                    requiredEquipment: [.kettlebell, .gym],
                    excludedInjuries: [.lowerBack, .knee, .wrist]),
            ]

        case .calisthenics:
            return [
                ExerciseTemplate(name: "Dominadas", sets: 4, reps: "Máx",
                    requiredEquipment: [.pullupBar, .trx, .gym],
                    excludedInjuries: [.shoulder, .elbow, .wrist]),
                ExerciseTemplate(name: "Fondos en paralelas", sets: 3, reps: "8-12",
                    requiredEquipment: [.pullupBar, .gym],
                    excludedInjuries: [.shoulder, .wrist, .elbow]),
                ExerciseTemplate(name: "Flexiones", sets: 4, reps: "15-20",
                    excludedInjuries: [.shoulder, .wrist, .elbow]),
                ExerciseTemplate(name: "Sentadilla búlgara", sets: 3, reps: "10 c/lado",
                    excludedInjuries: [.knee, .hip, .ankle]),
                ExerciseTemplate(name: "Plancha frontal", sets: 3, durationSeconds: 45,
                    excludedInjuries: [.lowerBack, .wrist, .shoulder]),
                ExerciseTemplate(name: "Remo en TRX", sets: 3, reps: "12-15",
                    requiredEquipment: [.trx],
                    excludedInjuries: [.shoulder, .elbow]),
                ExerciseTemplate(name: "Pistol squat (asistido)", sets: 3, reps: "5-8 c/lado",
                    excludedInjuries: [.knee, .hip, .ankle]),
            ]

        case .running:
            return [
                ExerciseTemplate(name: "Calentamiento dinámico", durationSeconds: 300,
                    restSeconds: 0,
                    notes: "Movilidad de caderas, talones al glúteo, rodillas al pecho"),
                ExerciseTemplate(name: "Carrera continua Z2", durationSeconds: 1800,
                    restSeconds: 0,
                    excludedInjuries: [.knee, .ankle, .hip],
                    notes: "Zona 2: puedes mantener conversación"),
                ExerciseTemplate(name: "Strides (aceleraciones cortas)", sets: 4, durationSeconds: 20,
                    restSeconds: 60,
                    excludedInjuries: [.knee, .ankle],
                    notes: "Acelera al 85-90% durante 20s"),
                ExerciseTemplate(name: "Vuelta a la calma", durationSeconds: 300,
                    restSeconds: 0,
                    notes: "Trote suave + estiramientos estáticos"),
            ]

        case .cycling:
            return [
                ExerciseTemplate(name: "Pedaleo de calentamiento", durationSeconds: 600,
                    requiredEquipment: [.bike, .gym],
                    restSeconds: 0,
                    notes: "Cadencia alta, resistencia baja"),
                ExerciseTemplate(name: "Intervalos aeróbicos Z3", sets: 4, durationSeconds: 300,
                    requiredEquipment: [.bike, .gym],
                    restSeconds: 120,
                    notes: "Potencia moderada-alta, mantén cadencia > 80 rpm"),
                ExerciseTemplate(name: "Sprint final", sets: 3, durationSeconds: 30,
                    requiredEquipment: [.bike, .gym],
                    restSeconds: 90,
                    notes: "Máxima potencia"),
                ExerciseTemplate(name: "Enfriamiento en bicicleta", durationSeconds: 300,
                    requiredEquipment: [.bike, .gym],
                    restSeconds: 0,
                    notes: "Resistencia mínima"),
            ]

        case .swimming:
            return [
                ExerciseTemplate(name: "Calentamiento crol suave", durationSeconds: 300,
                    requiredEquipment: [.pool],
                    restSeconds: 30,
                    notes: "50m a ritmo fácil"),
                ExerciseTemplate(name: "Series de crol", sets: 6, durationSeconds: 60,
                    requiredEquipment: [.pool],
                    restSeconds: 30,
                    excludedInjuries: [.shoulder],
                    notes: "50m a ritmo moderado-alto"),
                ExerciseTemplate(name: "Espalda libre", sets: 3, durationSeconds: 60,
                    requiredEquipment: [.pool],
                    restSeconds: 30,
                    notes: "50m espalda a ritmo suave"),
                ExerciseTemplate(name: "Patada con tabla", sets: 4, durationSeconds: 45,
                    requiredEquipment: [.pool],
                    restSeconds: 30,
                    notes: "Trabaja solo la patada"),
            ]

        case .walking:
            return [
                ExerciseTemplate(name: "Caminata a ritmo normal", durationSeconds: 1800,
                    restSeconds: 0,
                    notes: "Terreno llano o ligero desnivel"),
                ExerciseTemplate(name: "Caminata a paso vivo", durationSeconds: 1200,
                    restSeconds: 0,
                    notes: "Incrementa el ritmo cardíaco ligeramente"),
                ExerciseTemplate(name: "Caminata con colinas", durationSeconds: 900,
                    restSeconds: 0,
                    excludedInjuries: [.knee, .hip],
                    notes: "Busca pendientes para mayor activación glúteos"),
            ]

        case .hiit:
            return [
                ExerciseTemplate(name: "Calentamiento movilidad", durationSeconds: 300,
                    restSeconds: 0),
                ExerciseTemplate(name: "Burpees", sets: 4, durationSeconds: 30,
                    restSeconds: 30,
                    excludedInjuries: [.shoulder, .wrist, .knee, .lowerBack]),
                ExerciseTemplate(name: "Jumping Jacks", sets: 4, durationSeconds: 30,
                    restSeconds: 20,
                    excludedInjuries: [.ankle, .knee]),
                ExerciseTemplate(name: "Mountain climbers", sets: 4, durationSeconds: 30,
                    restSeconds: 20,
                    excludedInjuries: [.wrist, .shoulder, .lowerBack]),
                ExerciseTemplate(name: "Squat jumps", sets: 4, durationSeconds: 20,
                    restSeconds: 40,
                    excludedInjuries: [.knee, .ankle, .hip]),
                ExerciseTemplate(name: "High knees", sets: 4, durationSeconds: 30,
                    restSeconds: 20,
                    excludedInjuries: [.knee, .hip, .ankle]),
                ExerciseTemplate(name: "Enfriamiento y estiramientos", durationSeconds: 300,
                    restSeconds: 0),
            ]

        case .yoga:
            return [
                ExerciseTemplate(name: "Saludo al Sol (Surya Namaskar)", sets: 5, reps: "completo",
                    excludedInjuries: [.wrist]),
                ExerciseTemplate(name: "Guerrero I y II", sets: 3, durationSeconds: 60,
                    notes: "30s cada lado"),
                ExerciseTemplate(name: "Perro boca abajo (Adho Mukha)", durationSeconds: 120,
                    excludedInjuries: [.wrist, .shoulder]),
                ExerciseTemplate(name: "Torsión sentado", sets: 3, durationSeconds: 30,
                    excludedInjuries: [.lowerBack]),
                ExerciseTemplate(name: "Postura del niño (Balasana)", durationSeconds: 120,
                    restSeconds: 0,
                    notes: "Respiración profunda, relaja la espalda"),
                ExerciseTemplate(name: "Savasana", durationSeconds: 300,
                    restSeconds: 0,
                    notes: "Cierra los ojos, respiración diafragmática lenta"),
            ]

        case .pilates:
            return [
                ExerciseTemplate(name: "The Hundred", sets: 1, durationSeconds: 60,
                    excludedInjuries: [.neck, .lowerBack]),
                ExerciseTemplate(name: "Roll Up", sets: 8, reps: "completo",
                    excludedInjuries: [.lowerBack, .neck]),
                ExerciseTemplate(name: "Leg Circles", sets: 3, durationSeconds: 30,
                    notes: "Cada pierna"),
                ExerciseTemplate(name: "Single Leg Stretch", sets: 3, durationSeconds: 30,
                    excludedInjuries: [.neck, .hip]),
                ExerciseTemplate(name: "Side Kick Series", sets: 2, durationSeconds: 45,
                    notes: "Cada lado"),
                ExerciseTemplate(name: "Teaser", sets: 3, reps: "5-8",
                    excludedInjuries: [.lowerBack, .neck, .hip]),
            ]

        case .mobility:
            return [
                ExerciseTemplate(name: "Apertura de caderas (figura 4)", sets: 2, durationSeconds: 60,
                    excludedInjuries: [.hip, .knee],
                    notes: "Cada lado"),
                ExerciseTemplate(name: "Rotación torácica en suelo", sets: 2, durationSeconds: 45,
                    excludedInjuries: [.neck]),
                ExerciseTemplate(name: "Estiramiento de isquiotibiales", sets: 2, durationSeconds: 60,
                    notes: "Cada pierna, mantén la espalda recta"),
                ExerciseTemplate(name: "Movilidad de hombros", sets: 2, durationSeconds: 45,
                    excludedInjuries: [.shoulder]),
                ExerciseTemplate(name: "Foam roller cadena posterior", sets: 1, durationSeconds: 120,
                    notes: "Muslos, glúteos, espalda baja"),
                ExerciseTemplate(name: "Respiración diafragmática", sets: 3, durationSeconds: 60,
                    restSeconds: 0,
                    notes: "Inhala 4s, retén 4s, exhala 6s"),
            ]

        case .recreationalSports:
            return [
                ExerciseTemplate(name: "Calentamiento general", durationSeconds: 600,
                    restSeconds: 0,
                    notes: "Movilidad articular y activación cardiovascular"),
                ExerciseTemplate(name: "Práctica libre del deporte", durationSeconds: 2400,
                    restSeconds: 0,
                    notes: "Elige tu deporte favorito y disfruta"),
                ExerciseTemplate(name: "Enfriamiento y estiramientos", durationSeconds: 600,
                    restSeconds: 0),
            ]
        }
    }
    // swiftlint:enable function_body_length
}
