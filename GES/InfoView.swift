import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Ícono de la app + decreto
                    VStack(spacing: 12) {
                        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 84, height: 84)
                            .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                            .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.15),
                                    radius: 6, x: 0, y: 3)

                        Text("Basado en el Decreto Supremo N° 29\nMinisterio de Salud de Chile · Vigente desde el 1 de diciembre de 2025")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                    Divider()

                    bloqueInfo(
                        icono: "exclamationmark.triangle.fill",
                        color: .orange,
                        titulo: "Aplicación no oficial",
                        cuerpo: "Esta aplicación es un desarrollo independiente y no tiene afiliación, respaldo ni relación oficial con el Ministerio de Salud de Chile (MINSAL), el Fondo Nacional de Salud (FONASA), ninguna Institución de Salud Previsional (ISAPRE) ni ningún otro organismo del Estado."
                    )

                    bloqueInfo(
                        icono: "doc.text.fill",
                        color: .blue,
                        titulo: "Carácter de la información",
                        cuerpo: "Los contenidos de esta aplicación —incluyendo descripciones clínicas, plazos de garantía y criterios diagnósticos— son resúmenes elaborados con fines informativos y educativos a partir de normativa pública. No constituyen una fuente oficial, no tienen carácter normativo y pueden no reflejar actualizaciones posteriores a la publicación del decreto vigente."
                    )

                    bloqueInfo(
                        icono: "cross.case.fill",
                        color: .red,
                        titulo: "No reemplaza la atención clínica",
                        cuerpo: "La información aquí presentada no sustituye el juicio clínico de profesionales de la salud habilitados ni la relación médico-paciente. Ante cualquier situación de salud, consulte a su médico u otro profesional competente."
                    )

                    bloqueInfo(
                        icono: "shield.fill",
                        color: .gray,
                        titulo: "Limitación de responsabilidad",
                        cuerpo: "El desarrollador no garantiza la exactitud, completitud, vigencia ni idoneidad de la información para un propósito determinado. El uso de esta aplicación es de exclusiva responsabilidad del usuario. Para información oficial y vinculante sobre las Garantías Explícitas en Salud, consulte directamente al MINSAL o a su prestador de salud."
                    )

                    bloqueInfo(
                        icono: "book.closed.fill",
                        color: .indigo,
                        titulo: "Fuente normativa",
                        cuerpo: "Los contenidos referencian el Decreto Supremo N° 29 del Ministerio de Salud de Chile, que establece las Garantías Explícitas en Salud para el período 2025–2028. Dicho decreto es un documento de dominio público del Estado de Chile."
                    )

                    Text("Versión de datos: DS N° 29 · 2025–2028")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Acerca de esta app")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    private func bloqueInfo(icono: String, color: Color, titulo: String, cuerpo: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icono)
                    .foregroundColor(color)
                Text(titulo)
                    .font(.headline)
            }
            Text(cuerpo)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    InfoView()
}
