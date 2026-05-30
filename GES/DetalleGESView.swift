import SwiftUI

struct DetalleGESView: View {
    let problema: ProblemaGES
    @AppStorage("favoritos") private var favoritosString = ""
    @State private var mostrarGuia = false
    @State private var mostrarFlujograma = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var contraste
    @ScaledMetric(relativeTo: .title2) private var headerIconSize: CGFloat = 52

    private var esFavorito: Bool {
        favoritosString.asFavoritosSet().contains(problema.id)
    }

    /// Opacidad de fondo de las tarjetas, reforzada cuando el usuario pide más contraste.
    private func fondoOpacidad(_ base: Double) -> Double {
        contraste == .increased ? min(base * 2.2, 0.4) : base
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                if problema.estadoDS29 != .vigente {
                    alertaDS29Section
                }
                seccionIngreso
                if let flujograma = problema.flujogramaDerivacion {
                    seccionFlujograma(nombreImagen: flujograma)
                }
                seccionInfo(titulo: "Descripción", icono: "info.circle.fill", contenido: problema.descripcion)
                seccionInfo(titulo: "Población Objetivo", icono: "person.2.fill", contenido: problema.poblacionObjetivo)
                seccionInfo(titulo: "Sospecha Diagnóstica", icono: "magnifyingglass", contenido: problema.sospechaDiagnostica)
                seccionInfo(titulo: "Confirmación Diagnóstica", icono: "checkmark.seal.fill", contenido: problema.confirmacionDiagnostica)
                seccionInfo(titulo: "Garantía de Oportunidad", icono: "clock.fill", contenido: problema.garantiaOportunidad)
                seccionInfo(titulo: "Tratamiento", icono: "cross.case.fill", contenido: problema.tratamiento)
                seccionInfo(titulo: "Seguimiento", icono: "arrow.triangle.2.circlepath", contenido: problema.seguimiento)

                if let archivo = problema.archivoGuiaSIGGES {
                    Button {
                        mostrarGuia = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.richtext")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ver Guía para SIGGES")
                                    .fontWeight(.semibold)
                                if problema.estadoDS29 == .modificado {
                                    Text("Guía del decreto anterior")
                                        .font(.caption)
                                        .opacity(0.85)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(problema.categoria.color)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityInputLabels(["Ver guía", "Guía", "Guía SIGGES"])
                    .sheet(isPresented: $mostrarGuia) {
                        GuiaSIGGESView(nombreArchivo: archivo, problema: problema)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("GES #\(problema.id)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    toggleFavorito()
                } label: {
                    Image(systemName: esFavorito ? "star.fill" : "star")
                        .foregroundColor(esFavorito ? .yellow : .gray)
                }
                .accessibilityLabel(esFavorito ? "Quitar de favoritos" : "Agregar a favoritos")
                .accessibilityValue(esFavorito ? "Favorito" : "")
                .accessibilityAddTraits(esFavorito ? .isSelected : [])
                .accessibilityInputLabels(["Favorito", "Marcar favorito"])
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: problema.categoria.icono)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: headerIconSize, height: headerIconSize)
                    .background(problema.categoria.color.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("GES #\(problema.id)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text(problema.nombre)
                        .font(.title3)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // En tamaños de texto accesibles las dos píldoras se apilan para no desbordar.
            let layoutPildoras = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                : AnyLayout(HStackLayout(spacing: 8))
            layoutPildoras {
                Text(problema.categoria.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(problema.categoria.color.opacity(fondoOpacidad(0.15)))
                    .foregroundColor(problema.categoria.color)
                    .clipShape(Capsule())

                HStack(spacing: 4) {
                    Image(systemName: problema.nivelIngreso.icono)
                        .font(.caption)
                        .accessibilityHidden(true)
                    Text(problema.nivelIngreso.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(problema.nivelIngreso.color.opacity(fondoOpacidad(0.15)))
                .foregroundColor(problema.nivelIngreso.color)
                .clipShape(Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var alertaDS29Section: some View {
        let esNuevo = problema.estadoDS29 == .nuevo
        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.title3)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(esNuevo ? "Nuevo en DS N°29 (2025–2028)" : "Modificado en DS N°29 (2025–2028)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
                Text(esNuevo
                     ? "Problema de salud incorporado por el DS N°29, vigente desde el 1 de diciembre de 2025. La información puede no haber sido validada contra una guía SIGGES oficial."
                     : "Este problema fue modificado por el DS N°29, vigente desde el 1 de diciembre de 2025. El contenido podría no reflejar los cambios del nuevo decreto. La guía SIGGES disponible corresponde al decreto anterior.")
                    .font(.caption)
                    .foregroundStyle(.primary.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(fondoOpacidad(0.10)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.orange.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private var seccionIngreso: some View {
        let nivel = problema.nivelIngreso
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: nivel.icono)
                    .foregroundColor(nivel.color)
                    .accessibilityHidden(true)
                Text("Ingreso al sistema GES")
                    .font(.headline)
            }
            Text(nivel.procesoGES)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(nivel.color.opacity(fondoOpacidad(0.07)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(nivel.color.opacity(0.25), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private func seccionFlujograma(nombreImagen: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "flowchart.fill")
                    .foregroundColor(problema.categoria.color)
                    .accessibilityHidden(true)
                Text("Flujograma de derivación")
                    .font(.headline)
                Spacer()
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }

            Button {
                mostrarFlujograma = true
            } label: {
                Image(nombreImagen)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Flujograma de derivación del proceso GES. Toca para ampliar.")
            .accessibilityInputLabels(["Flujograma", "Ampliar flujograma"])

            Text("Extraído de la sección «Flujo de Proceso» de la guía SIGGES. Toca para ampliar.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .sheet(isPresented: $mostrarFlujograma) {
            FlujogramaZoomView(nombreImagen: nombreImagen, titulo: problema.nombre)
        }
    }

    @ViewBuilder
    private func seccionInfo(titulo: String, icono: String, contenido: String) -> some View {
        if !contenido.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: icono)
                        .foregroundColor(problema.categoria.color)
                        .accessibilityHidden(true)
                    Text(titulo)
                        .font(.headline)
                }

                Text(contenido)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityElement(children: .combine)
        }
    }

    private func toggleFavorito() {
        var set = favoritosString.asFavoritosSet()
        if set.contains(problema.id) {
            set.remove(problema.id)
        } else {
            set.insert(problema.id)
        }
        favoritosString = set.sorted().map(String.init).joined(separator: ",")
    }
}

// MARK: - Visor de flujograma con zoom

/// Presenta el flujograma a pantalla completa con pinch-to-zoom y desplazamiento,
/// usando un `UIScrollView` nativo para una experiencia fluida.
struct FlujogramaZoomView: View {
    let nombreImagen: String
    let titulo: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZoomableImageView(nombreImagen: nombreImagen)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(titulo)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cerrar") { dismiss() }
                    }
                }
        }
    }
}

struct ZoomableImageView: UIViewRepresentable {
    let nombreImagen: String

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 6
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .systemBackground

        let imageView = UIImageView(image: UIImage(named: nombreImagen))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        // Doble toque para alternar entre ajuste y acercamiento.
        let doblePulsacion = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.manejarDoblePulsacion(_:))
        )
        doblePulsacion.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doblePulsacion)

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        weak var imageView: UIImageView?

        func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }

        @objc func manejarDoblePulsacion(_ gesto: UITapGestureRecognizer) {
            guard let scrollView = gesto.view as? UIScrollView else { return }
            if scrollView.zoomScale > scrollView.minimumZoomScale {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                let punto = gesto.location(in: imageView)
                let nuevoZoom = min(scrollView.maximumZoomScale, 3)
                let ancho = scrollView.bounds.width / nuevoZoom
                let alto = scrollView.bounds.height / nuevoZoom
                let rect = CGRect(x: punto.x - ancho / 2, y: punto.y - alto / 2, width: ancho, height: alto)
                scrollView.zoom(to: rect, animated: true)
            }
        }
    }
}
