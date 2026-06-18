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
                        Image("GESAppIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 84, height: 84)
                            .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                            .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.15),
                                    radius: 6, x: 0, y: 3)
                            .accessibilityHidden(true)

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

                    bloqueFuentes

                    Text("Hecha en Chile 🇨🇱")
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

    /// Bloque "Fuente normativa" con citas y enlaces a las fuentes oficiales.
    /// Cumple el requisito de la guía 1.4.1: citas accesibles y enlaces a la fuente.
    private var bloqueFuentes: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                    .foregroundColor(.indigo)
                    .accessibilityHidden(true)
                Text("Fuentes y citas")
                    .font(.headline)
            }

            Text("Los contenidos referencian el Decreto Supremo N° 29 del Ministerio de Salud de Chile, que establece las Garantías Explícitas en Salud para el período 2025–2028. Las guías para SIGGES incluidas son guías clínicas publicadas por el Ministerio de Salud. Ambos son documentos de dominio público del Estado de Chile.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Link(destination: FuentesGES.decretoURL) {
                enlaceFuente(icono: "doc.text.magnifyingglass",
                             titulo: "Texto oficial del DS N° 29 (LeyChile)",
                             detalle: "Biblioteca del Congreso Nacional")
            }

            Link(destination: FuentesGES.minsalURL) {
                enlaceFuente(icono: "cross.case.fill",
                             titulo: "Guías clínicas GES / AUGE (MINSAL)",
                             detalle: "auge.minsal.cl")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func enlaceFuente(icono: String, titulo: String, detalle: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icono)
                .foregroundColor(.blue)
                .frame(width: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(detalle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "arrow.up.right.square")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isLink)
    }

    private func bloqueInfo(icono: String, color: Color, titulo: String, cuerpo: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icono)
                    .foregroundColor(color)
                    .accessibilityHidden(true)
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
