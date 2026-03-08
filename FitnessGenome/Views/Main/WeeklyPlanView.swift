// WeeklyPlanView.swift
// FitnessGenome
// Vista que muestra el plan semanal generado con sus sesiones

import SwiftUI

struct WeeklyPlanView: View {

    let plan: WeeklyPlan

    var body: some View {
        VStack(spacing: 16) {
            planHeader
            sessionsList
            volumeCard
            if !plan.planNotes.isEmpty {
                notesCard
            }
        }
    }

    // MARK: - Cabecera del plan

    private var planHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Plan semanal")
                    .font(.headline)
                Text(weekRangeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(phaseName)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(phaseColor.opacity(0.15))
                .foregroundStyle(phaseColor)
                .clipShape(Capsule())
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Lista de sesiones

    private var sessionsList: some View {
        VStack(spacing: 10) {
            ForEach(plan.sessions.sorted(by: { $0.dayOfWeek < $1.dayOfWeek })) { session in
                PlannedSessionCard(session: session)
            }
        }
    }

    // MARK: - Resumen de volumen

    private var volumeCard: some View {
        let vol = plan.totalVolume
        let total = max(vol.total, 1)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Volumen total — \(vol.total) min")
                .font(.subheadline.weight(.semibold))

            if vol.strengthMinutes > 0 {
                VolumeBar(label: "Fuerza", minutes: vol.strengthMinutes,
                          fraction: Double(vol.strengthMinutes) / Double(total),
                          color: .fgOrange)
            }
            if vol.cardioMinutes > 0 {
                VolumeBar(label: "Cardio", minutes: vol.cardioMinutes,
                          fraction: Double(vol.cardioMinutes) / Double(total),
                          color: .fgBlue)
            }
            if vol.mindBodyMinutes > 0 {
                VolumeBar(label: "Mente-Cuerpo", minutes: vol.mindBodyMinutes,
                          fraction: Double(vol.mindBodyMinutes) / Double(total),
                          color: .fgPurple)
            }
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Notas del plan

    private var notesCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(Color.fgOrange)
                .font(.subheadline)
            Text(plan.planNotes)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .cardStyle(cornerRadius: 12)
    }

    // MARK: - Helpers

    private var phaseName: String {
        switch plan.weekNumber % 4 {
        case 1: return "Adaptación"
        case 2: return "Acumulación"
        case 3: return "Intensificación"
        default: return "Descarga"
        }
    }

    private var phaseColor: Color {
        switch plan.weekNumber % 4 {
        case 1: return .fgBlue
        case 2: return .fgGreen
        case 3: return .fgOrange
        default: return .secondary
        }
    }

    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "es_ES")
        let start = plan.weekStartDate
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
        return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
    }
}

// MARK: - Tarjeta de sesión planificada

private struct PlannedSessionCard: View {

    let session: PlannedSession
    @State private var expanded = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) { expanded.toggle() }
        } label: {
            VStack(spacing: 0) {
                mainRow
                if expanded {
                    exercisesSection
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(14)
            .cardStyle(cornerRadius: 12)
        }
        .buttonStyle(.plain)
    }

    private var mainRow: some View {
        HStack(spacing: 12) {
            // Indicador de intensidad
            RoundedRectangle(cornerRadius: 3)
                .fill(intensityColor)
                .frame(width: 4, height: 44)

            // Icono de actividad
            Image(systemName: session.activity?.icon ?? "figure.walk")
                .font(.title3)
                .foregroundStyle(intensityColor)
                .frame(width: 28)

            // Info principal
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(session.dayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(session.durationMinutes) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(session.activity?.displayName ?? session.activityType)
                    .font(.subheadline.weight(.semibold))
                Text(session.focus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            // Badge de intensidad
            Text(session.intensity.displayName)
                .font(.caption2.weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(intensityColor.opacity(0.15))
                .foregroundStyle(intensityColor)
                .clipShape(Capsule())
        }
    }

    @ViewBuilder
    private var exercisesSection: some View {
        if !session.exercises.isEmpty {
            Divider().padding(.vertical, 8)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(session.exercises) { exercise in
                    ExerciseRow(exercise: exercise)
                }
            }
        } else {
            Divider().padding(.vertical, 8)
            Text("Toca para ver los ejercicios cuando registres la sesión.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }

    private var intensityColor: Color {
        switch session.intensity {
        case .recovery:  return .fgBlue
        case .light:     return .fgGreen
        case .moderate:  return .fgOrange
        case .hard:      return .orange
        case .maxEffort: return .red
        }
    }
}

// MARK: - Fila de ejercicio

private struct ExerciseRow: View {
    let exercise: ExercisePlan

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 6, height: 6)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 1) {
                Text(exercise.name)
                    .font(.caption.weight(.medium))
                Text(exerciseDetail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var exerciseDetail: String {
        var parts: [String] = []
        if let sets = exercise.sets { parts.append("\(sets) series") }
        if let reps = exercise.reps { parts.append(reps) }
        if let secs = exercise.durationSeconds { parts.append("\(secs)s") }
        if !exercise.notes.isEmpty { parts.append(exercise.notes) }
        return parts.joined(separator: " · ")
    }
}

// MARK: - Barra de volumen

private struct VolumeBar: View {
    let label: String
    let minutes: Int
    let fraction: Double
    let color: Color
    @State private var animated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(minutes) min")
                    .font(.caption.bold())
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.12))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * (animated ? fraction : 0))
                        .animation(.spring(duration: 0.9).delay(0.1), value: animated)
                }
            }
            .frame(height: 6)
            .onAppear { animated = true }
        }
    }
}

#Preview {
    ScrollView {
        WeeklyPlanView(plan: {
            let p = WeeklyPlan(
                userId: UUID(),
                weekStartDate: Date(),
                weekNumber: 2,
                genomeVersion: 1
            )
            p.sessions = [
                PlannedSession(dayOfWeek: 1, activityType: .weightTraining,
                               durationMinutes: 55, intensity: .moderate,
                               focus: "Musculación — Acumulación"),
                PlannedSession(dayOfWeek: 3, activityType: .running,
                               durationMinutes: 40, intensity: .hard,
                               focus: "Running — Máximo rendimiento"),
                PlannedSession(dayOfWeek: 5, activityType: .yoga,
                               durationMinutes: 35, intensity: .light,
                               focus: "Yoga — Aprendizaje técnico"),
            ]
            p.totalVolume = PlanVolume(strengthMinutes: 55, cardioMinutes: 40,
                                       mindBodyMinutes: 35, recoveryMinutes: 15)
            p.planNotes = "Semana de Acumulación. Tu punto fuerte: Fuerza."
            return p
        }())
        .padding(.horizontal, 20)
    }
}
