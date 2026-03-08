// TimeEquipmentStepView.swift
// FitnessGenome
// Paso 6: Disponibilidad de tiempo y equipamiento

import SwiftUI

struct TimeEquipmentStepView: View {
    @Bindable var vm: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                stepHeader
                    .fadeInOnAppear(delay: 0.0)

                daysSection
                    .fadeInOnAppear(delay: 0.1)

                durationSection
                    .fadeInOnAppear(delay: 0.2)

                equipmentSection
                    .fadeInOnAppear(delay: 0.3)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    // MARK: - Header

    private var stepHeader: some View {
        VStack(spacing: 6) {
            Text("Tu disponibilidad")
                .font(.title2.bold())
            Text("Adaptamos el plan a tu tiempo\ny recursos reales.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Días por semana

    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Días disponibles por semana")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(Int(vm.availableDaysPerWeek)) días")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.fgGreen)
            }

            // Selector visual de días
            HStack(spacing: 8) {
                ForEach(2...7, id: \.self) { day in
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            vm.availableDaysPerWeek = Double(day)
                        }
                    } label: {
                        Text("\(day)")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Int(vm.availableDaysPerWeek) == day ? Color.fgGreen : Color.secondary.opacity(0.1))
                            .foregroundStyle(Int(vm.availableDaysPerWeek) == day ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }

            Text(daysRecommendation)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .cardStyle()
    }

    private var daysRecommendation: String {
        switch Int(vm.availableDaysPerWeek) {
        case 2: return "Mínimo recomendado. Plan de alta eficiencia."
        case 3: return "Ideal para comenzar. Buen equilibrio trabajo/descanso."
        case 4: return "Excelente. Permite buena variedad de actividades."
        case 5: return "Óptimo para progresar rápido con buena recuperación."
        case 6: return "Avanzado. Incluiremos días de recuperación activa."
        case 7: return "Entrenamiento diario — incluiremos sesiones muy suaves."
        default: return ""
        }
    }

    // MARK: - Duración por sesión

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Duración por sesión")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(Int(vm.sessionDurationMinutes)) min")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.fgGreen)
            }

            Slider(value: $vm.sessionDurationMinutes, in: 20...120, step: 5)
                .tint(Color.fgGreen)

            HStack {
                Text("20 min").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("2 horas").font(.caption).foregroundStyle(.secondary)
            }

            Text(durationNote)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .cardStyle()
    }

    private var durationNote: String {
        let min = Int(vm.sessionDurationMinutes)
        switch min {
        case ..<30: return "Sesiones express — máxima eficiencia en poco tiempo."
        case 30..<45: return "Sesiones cortas pero efectivas con buena estructura."
        case 45..<60: return "Duración estándar. Permite calentamiento, trabajo y vuelta a la calma."
        case 60..<90: return "Sesiones completas con tiempo para técnica y volumen."
        default: return "Sesiones largas — ideal para disciplinas como natación o ciclismo."
        }
    }

    // MARK: - Equipamiento

    private var equipmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Equipamiento disponible")
                    .font(.subheadline.weight(.semibold))
                Text("Selecciona todo lo que tienes acceso")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(EquipmentType.allCases) { equipment in
                    EquipmentChip(
                        equipment: equipment,
                        isSelected: vm.selectedEquipment.contains(equipment)
                    ) {
                        withAnimation(.spring(duration: 0.25)) {
                            if vm.selectedEquipment.contains(equipment) {
                                // No permitir deseleccionar si es el único
                                if vm.selectedEquipment.count > 1 {
                                    vm.selectedEquipment.remove(equipment)
                                }
                            } else {
                                vm.selectedEquipment.insert(equipment)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .cardStyle()
    }
}

// MARK: - Chip de equipamiento

private struct EquipmentChip: View {
    let equipment: EquipmentType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: equipment.icon)
                    .font(.subheadline)
                    .foregroundStyle(isSelected ? .white : Color.fgBlue)
                    .frame(width: 20)

                Text(equipment.displayName)
                    .font(.caption.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.fgBlue : Color.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .animation(.spring(duration: 0.25), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimeEquipmentStepView(vm: OnboardingViewModel())
}
