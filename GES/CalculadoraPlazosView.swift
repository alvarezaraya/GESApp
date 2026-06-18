import SwiftUI

/// Calculadora de plazos de garantía GES. El usuario elige una fecha de inicio
/// (p. ej. la confirmación diagnóstica) y un plazo, y la app calcula la fecha
/// límite y los días/horas que faltan. Los plazos GES se cuentan en días corridos
/// desde la fecha que fija cada garantía en el decreto.
struct CalculadoraPlazosView: View {
    @Environment(\.dismiss) private var dismiss

    private enum Unidad: String, CaseIterable, Identifiable {
        case horas = "Horas"
        case dias = "Días corridos"
        var id: String { rawValue }
        var componente: Calendar.Component { self == .horas ? .hour : .day }
        var presets: [Int] {
            self == .horas ? [24, 48, 72] : [5, 7, 10, 14, 20, 30, 45, 60, 90, 120, 180]
        }
    }

    @State private var fechaInicio = Date()
    @State private var unidad: Unidad = .dias
    @State private var cantidad = 30

    private var fechaLimite: Date? {
        Calendar.current.date(byAdding: unidad.componente, value: cantidad, to: fechaInicio)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    introSection
                    entradaSection
                    if let limite = fechaLimite {
                        resultadoSection(limite: limite)
                    }
                    notaSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Calculadora de plazos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    private var introSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "clock.badge.checkmark.fill")
                .font(.title2)
                .foregroundStyle(.blue)
                .accessibilityHidden(true)
            Text("Calcula la fecha límite de una garantía de oportunidad a partir de su fecha de inicio.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var entradaSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            DatePicker("Fecha de inicio",
                       selection: $fechaInicio,
                       displayedComponents: .date)
                .datePickerStyle(.compact)

            Divider()

            Picker("Unidad", selection: $unidad) {
                ForEach(Unidad.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: unidad) { _, nueva in
                // Ajusta la cantidad a un preset razonable de la nueva unidad.
                if !nueva.presets.contains(cantidad) {
                    cantidad = nueva == .horas ? 24 : 30
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Plazo de la garantía")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(cantidad) \(unidad == .horas ? "h" : "días")")
                        .font(.headline)
                        .monospacedDigit()
                }
                Stepper("Plazo", value: $cantidad, in: 1...365)
                    .labelsHidden()
                    .accessibilityLabel("Plazo en \(unidad.rawValue)")
                    .accessibilityValue("\(cantidad)")
            }

            // Atajos a los plazos GES más frecuentes.
            FlowChips(valores: unidad.presets, seleccion: $cantidad,
                      sufijo: unidad == .horas ? "h" : "d")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func resultadoSection(limite: Date) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fecha límite")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(limite.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            HStack(spacing: 8) {
                Image(systemName: iconoRestante(limite))
                    .foregroundStyle(colorRestante(limite))
                    .accessibilityHidden(true)
                Text(textoRestante(limite))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(colorRestante(limite))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private var notaSection: some View {
        Text("Cálculo referencial. El plazo y la fecha de inicio exactos de cada garantía están definidos en el Decreto Supremo N° 29 y en la ficha de cada problema de salud. Los plazos GES se cuentan, salvo excepción, en días corridos.")
            .font(.caption)
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 4)
    }

    // MARK: - Días restantes

    private func diasRestantes(_ limite: Date) -> Int {
        let inicio = Calendar.current.startOfDay(for: Date())
        let fin = Calendar.current.startOfDay(for: limite)
        return Calendar.current.dateComponents([.day], from: inicio, to: fin).day ?? 0
    }

    private func textoRestante(_ limite: Date) -> String {
        let d = diasRestantes(limite)
        if d > 1 { return "Faltan \(d) días" }
        if d == 1 { return "Falta 1 día (vence mañana)" }
        if d == 0 { return "Vence hoy" }
        if d == -1 { return "Venció ayer (hace 1 día)" }
        return "Vencido hace \(-d) días"
    }

    private func iconoRestante(_ limite: Date) -> String {
        let d = diasRestantes(limite)
        if d < 0 { return "exclamationmark.octagon.fill" }
        if d <= 2 { return "exclamationmark.triangle.fill" }
        return "checkmark.circle.fill"
    }

    private func colorRestante(_ limite: Date) -> Color {
        let d = diasRestantes(limite)
        if d < 0 { return .red }
        if d <= 2 { return .orange }
        return .green
    }
}

/// Fila de chips de plazos frecuentes que se ajusta a varias líneas.
private struct FlowChips: View {
    let valores: [Int]
    @Binding var seleccion: Int
    let sufijo: String

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 52), spacing: 8)], spacing: 8) {
            ForEach(valores, id: \.self) { valor in
                let activo = valor == seleccion
                Button {
                    seleccion = valor
                } label: {
                    Text("\(valor)\(sufijo)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(activo ? Color.blue : Color.blue.opacity(0.12))
                        .foregroundColor(activo ? .white : .blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .accessibilityLabel("\(valor) \(sufijo == "h" ? "horas" : "días")")
                .accessibilityAddTraits(activo ? .isSelected : [])
            }
        }
    }
}

#Preview { CalculadoraPlazosView() }
