import SwiftUI
import AppIntents

/// Snippet interactivo mostrado por `ConsultarProblemaIntent` en Siri/Spotlight.
/// Resume el PS y ofrece un botón para abrir la ficha completa en la app.
struct ResumenPSView: View {
    let problema: ProblemaGES

    private var abrirIntent: AbrirProblemaIntent {
        let intent = AbrirProblemaIntent()
        intent.target = ProblemaGESEntity(problema)
        return intent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: problema.categoria.icono)
                    .font(.title2)
                    .foregroundStyle(problema.categoria.color)
                    .frame(width: 36, height: 36)
                    .background(problema.categoria.color.opacity(0.15), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("PS \(problema.id) · \(problema.categoria.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(problema.nombre)
                        .font(.headline)
                        .lineLimit(2)
                }
            }

            Text(problema.descripcion)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(4)

            Button(intent: abrirIntent) {
                Label("Ver ficha completa", systemImage: "arrow.up.forward.app")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(problema.categoria.color)
        }
        .padding()
    }
}
