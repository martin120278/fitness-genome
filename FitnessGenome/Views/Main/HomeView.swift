// HomeView.swift
// FitnessGenome
// Pantalla principal post-onboarding (placeholder hasta siguiente feature)

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query private var genomes: [FitnessGenomeModel]

    private var profile: UserProfile? { profiles.first }
    private var genome: FitnessGenomeModel? { genomes.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    greetingHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    genomeCard
                        .padding(.horizontal, 20)

                    comingSoonBanner
                        .padding(.horizontal, 20)

                    Spacer(minLength: 32)
                }
            }
            .navigationTitle("Fitness Genome")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Saludo

    private var greetingHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.title2.bold())
                if let profile {
                    Text(profile.primaryGoal.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.fgGreen, .fgBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                Text(initials)
                    .font(.headline.bold())
                    .foregroundStyle(.white)
            }
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let prefix: String
        switch hour {
        case 5..<12:  prefix = "Buenos días"
        case 12..<18: prefix = "Buenas tardes"
        default:      prefix = "Buenas noches"
        }
        if let name = profile?.name, !name.isEmpty {
            return "\(prefix), \(name)"
        }
        return prefix
    }

    private var initials: String {
        guard let name = profile?.name, !name.isEmpty else { return "FG" }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    // MARK: - Genome card

    private var genomeCard: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Tu Fitness Genome", systemImage: "dna")
                    .font(.headline)
                Spacer()
                if let genome {
                    Text("v\(genome.version)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let genome {
                let dims: [(String, Double, Color)] = [
                    ("Fuerza", genome.strengthScore, .fgOrange),
                    ("Resistencia", genome.enduranceScore, .fgBlue),
                    ("Movilidad", genome.mobilityScore, .fgPurple),
                    ("Recuperación", genome.recoveryScore, .fgGreen)
                ]

                ForEach(dims, id: \.0) { name, val, color in
                    HomeDimensionRow(name: name, value: val, color: color)
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Banner próximas features

    private var comingSoonBanner: some View {
        VStack(spacing: 14) {
            Text("Próximamente")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(upcomingFeatures, id: \.0) { icon, title, desc in
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(Color.fgGreen)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.subheadline.weight(.medium))
                        Text(desc).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    private var upcomingFeatures: [(String, String, String)] {[
        ("calendar.badge.plus", "Plan semanal inteligente", "Combinación óptima de actividades"),
        ("checkmark.circle.fill", "Registro post-sesión", "Feedback y métricas de cada entrenamiento"),
        ("heart.text.square.fill", "Integración HealthKit", "Pasos, sueño, HR y workouts automáticos"),
        ("chart.line.uptrend.xyaxis", "Dashboard de progreso", "Evolución de tu Genome semana a semana")
    ]}
}

// MARK: - Fila de dimensión del genome

private struct HomeDimensionRow: View {
    let name: String
    let value: Double
    let color: Color

    @State private var animated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.12))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * (animated ? value : 0))
                        .animation(.spring(duration: 1.0).delay(0.1), value: animated)
                }
            }
            .frame(height: 7)
            .onAppear { animated = true }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [UserProfile.self, FitnessGenomeModel.self], inMemory: true)
}
