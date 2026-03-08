// OnboardingViewModel.swift
// FitnessGenome
// ViewModel que gestiona todo el flujo de onboarding multi-paso

import SwiftUI
import SwiftData
import Observation

@Observable
@MainActor
final class OnboardingViewModel {

    // MARK: - Paso actual
    var currentStep: OnboardingStep = .welcome
    var isAnimatingTransition: Bool = false

    // MARK: - Datos capturados (se traspasan al UserProfile al final)

    // Paso 1: Bienvenida
    var userName: String = ""

    // Paso 2: Datos personales
    var age: Double = 30
    var sex: BiologicalSex = .notSpecified
    var heightCm: Double = 170
    var weightKg: Double = 70

    // Paso 3: Nivel de fitness
    var overallFitnessLevel: FitnessLevel = .beginner

    // Paso 4: Lesiones
    var selectedInjuries: Set<InjuryType> = []
    var injuryNotes: String = ""

    // Paso 5: Objetivos
    var primaryGoal: FitnessGoal = .generalFitness
    var selectedSecondaryGoals: Set<FitnessGoal> = []

    // Paso 6: Disponibilidad y equipamiento
    var availableDaysPerWeek: Double = 3
    var sessionDurationMinutes: Double = 60
    var selectedEquipment: Set<EquipmentType> = [.bodyweight]

    // Paso 7: Sueño y estrés
    var averageSleepHours: Double = 7
    var stressLevel: StressLevel = .moderate

    // Paso 8: Experiencia por disciplina
    var disciplineExperience: [ActivityType: ExperienceLevel] = {
        var dict: [ActivityType: ExperienceLevel] = [:]
        ActivityType.allCases.forEach { dict[$0] = .none }
        return dict
    }()

    // Paso 9: Preferencias de actividad
    var preferredActivities: Set<ActivityType> = []
    var dislikedActivities: Set<ActivityType> = []

    // MARK: - Estado de guardado
    var isSaving: Bool = false
    var saveError: String? = nil

    // MARK: - Progreso
    var progress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }

    var isFirstStep: Bool { currentStep == .welcome }
    var isLastStep: Bool { currentStep == .complete }

    // MARK: - Navegación

    func goToNextStep() {
        guard let next = currentStep.next() else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep = next
        }
    }

    func goToPreviousStep() {
        guard let prev = currentStep.previous() else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep = prev
        }
    }

    func goToStep(_ step: OnboardingStep) {
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep = step
        }
    }

    // MARK: - Validación por paso

    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return !userName.trimmingCharacters(in: .whitespaces).isEmpty
        case .personalInfo:
            return age >= 14 && age <= 100 && heightCm >= 100 && heightCm <= 250 && weightKg >= 30 && weightKg <= 300
        case .fitnessLevel:
            return true
        case .injuries:
            return true
        case .goals:
            return true
        case .timeEquipment:
            return !selectedEquipment.isEmpty
        case .sleepStress:
            return true
        case .disciplineExperience:
            return true
        case .activityPreferences:
            return true
        case .complete:
            return true
        }
    }

    // MARK: - Guardar perfil en SwiftData

    func saveProfile(context: ModelContext) async {
        isSaving = true
        saveError = nil

        let profile = UserProfile()
        profile.name = userName.trimmingCharacters(in: .whitespaces)
        profile.age = Int(age)
        profile.sex = sex
        profile.heightCm = heightCm
        profile.weightKg = weightKg
        profile.overallFitnessLevel = overallFitnessLevel
        profile.injuries = Array(selectedInjuries).filter { $0 != .none }
        profile.injuryNotes = injuryNotes
        profile.primaryGoal = primaryGoal
        profile.secondaryGoals = Array(selectedSecondaryGoals)
        profile.availableDaysPerWeek = Int(availableDaysPerWeek)
        profile.sessionDurationMinutes = Int(sessionDurationMinutes)
        profile.availableEquipment = Array(selectedEquipment)
        profile.averageSleepHours = averageSleepHours
        profile.stressLevel = stressLevel

        // Experiencia por disciplina
        for (activity, level) in disciplineExperience {
            profile.setExperience(level, for: activity)
        }

        profile.preferredActivities = Array(preferredActivities).map { $0.rawValue }
        profile.dislikedActivities = Array(dislikedActivities).map { $0.rawValue }
        profile.hasCompletedOnboarding = true

        context.insert(profile)

        // Crear genome inicial
        let genome = FitnessGenomeModel(userId: profile.id)
        genome.calibrateFromProfile(profile)
        context.insert(genome)

        do {
            try context.save()
        } catch {
            saveError = "Error al guardar: \(error.localizedDescription)"
        }

        isSaving = false
    }
}

// MARK: - Pasos del onboarding

enum OnboardingStep: Int, CaseIterable {
    case welcome             = 0
    case personalInfo        = 1
    case fitnessLevel        = 2
    case injuries            = 3
    case goals               = 4
    case timeEquipment       = 5
    case sleepStress         = 6
    case disciplineExperience = 7
    case activityPreferences = 8
    case complete            = 9

    var title: String {
        switch self {
        case .welcome:              return "Bienvenido"
        case .personalInfo:         return "Datos personales"
        case .fitnessLevel:         return "Tu nivel actual"
        case .injuries:             return "Lesiones y limitaciones"
        case .goals:                return "Tus objetivos"
        case .timeEquipment:        return "Tiempo y equipamiento"
        case .sleepStress:          return "Sueño y estrés"
        case .disciplineExperience: return "Tu experiencia"
        case .activityPreferences:  return "Tus preferencias"
        case .complete:             return "Listo"
        }
    }

    var subtitle: String {
        switch self {
        case .welcome:              return "Tu entrenador inteligente"
        case .personalInfo:         return "Cuéntanos sobre ti"
        case .fitnessLevel:         return "Sé honesto, ¡no te juzgamos!"
        case .injuries:             return "Para protegerte y adaptar tu plan"
        case .goals:                return "¿Qué quieres lograr?"
        case .timeEquipment:        return "Adaptamos el plan a tu realidad"
        case .sleepStress:          return "El descanso es parte del entrenamiento"
        case .disciplineExperience: return "¿Cuánta experiencia tienes en cada área?"
        case .activityPreferences:  return "¿Qué actividades te gustan o no?"
        case .complete:             return "Tu Fitness Genome está listo"
        }
    }

    func next() -> OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }

    func previous() -> OnboardingStep? {
        guard rawValue > 0 else { return nil }
        return OnboardingStep(rawValue: rawValue - 1)
    }

    /// Pasos que muestran barra de progreso (excluye welcome y complete)
    var showsProgress: Bool {
        self != .welcome && self != .complete
    }
}
