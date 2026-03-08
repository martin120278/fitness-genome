// FitnessGenomeApp.swift
// FitnessGenome
// Entry point de la aplicación — configura SwiftData y el flujo principal

import SwiftUI
import SwiftData

@main
struct FitnessGenomeApp: App {

    // SwiftData container con todos los modelos persistibles
    private let modelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            FitnessGenomeModel.self,
            WeeklyPlan.self,
            SessionLog.self
        ])
        // Intentar primero con almacenamiento persistente; fallback en memoria
        if let container = try? ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)]
        ) {
            return container
        }
        return try! ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(modelContainer)
        }
    }
}

// MARK: - AppRootView — decide si mostrar onboarding o home

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    private var hasCompletedOnboarding: Bool {
        profiles.contains { $0.hasCompletedOnboarding }
    }

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                HomeView()
                    .transition(.opacity)
            } else {
                OnboardingContainerView {
                    // El onboarding guardó el perfil — SwiftData @Query se actualiza automáticamente
                    // y AppRootView transiciona a HomeView
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
    }
}
