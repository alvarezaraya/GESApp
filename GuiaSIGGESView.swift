import SwiftUI
import PDFKit

struct GuiaSIGGESView: View {
    let nombreArchivo: String
    let problema: ProblemaGES

    @State private var textoBusqueda = ""
    @State private var pdfView: PDFView?
    @State private var resultados: [PDFSelection] = []
    @State private var indiceActual: Int = 0
    @State private var documento: PDFDocument?
    @State private var cargaFinalizada = false

    var body: some View {
        NavigationStack {
            Group {
                if let documento {
                    visorPDF(documento)
                } else if cargaFinalizada {
                    ContentUnavailableView {
                        Label("No se pudo abrir la guía", systemImage: "doc.questionmark")
                    } description: {
                        Text("El archivo de la guía SIGGES no está disponible o está dañado.")
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(problema.nombre)
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            let archivo = nombreArchivo
            documento = await Task.detached(priority: .userInitiated) {
                Self.cargarDocumento(archivo)
            }.value
            cargaFinalizada = true
        }
    }

    private func visorPDF(_ documento: PDFDocument) -> some View {
        PDFKitView(documento: documento, onViewCreated: { pdfView = $0 })
            .ignoresSafeArea(edges: .bottom)
            .searchable(text: $textoBusqueda, prompt: "Buscar en guía…")
            .onChange(of: textoBusqueda) { _, query in
                reiniciarBusqueda()
                guard let pdfView, let doc = pdfView.document, !query.isEmpty else { return }
                Task.detached(priority: .userInitiated) {
                    let matches = doc.findString(query, withOptions: .caseInsensitive)
                    await MainActor.run {
                        resultados = matches
                        if !matches.isEmpty { navegarA(0) }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !textoBusqueda.isEmpty && !resultados.isEmpty {
                    navBar
                }
            }
    }

    private nonisolated static func cargarDocumento(_ nombreArchivo: String) -> PDFDocument? {
        guard let url = Bundle.main.resourceURL?.appendingPathComponent(nombreArchivo) else { return nil }
        return PDFDocument(url: url)
    }

    // MARK: - Barra de navegación de resultados

    private var navBar: some View {
        HStack(spacing: 20) {
            Button { navegar(delta: -1) } label: {
                Image(systemName: "chevron.up")
            }
            .disabled(resultados.count <= 1)
            .accessibilityLabel("Resultado anterior")

            Text("\(indiceActual + 1) de \(resultados.count)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .accessibilityLabel("Resultado \(indiceActual + 1) de \(resultados.count)")

            Button { navegar(delta: +1) } label: {
                Image(systemName: "chevron.down")
            }
            .disabled(resultados.count <= 1)
            .accessibilityLabel("Resultado siguiente")
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
    }

    // MARK: - Helpers

    private func reiniciarBusqueda() {
        pdfView?.document?.cancelFindString()
        pdfView?.clearSelection()
        resultados = []
        indiceActual = 0
    }

    private func navegar(delta: Int) {
        guard !resultados.isEmpty else { return }
        indiceActual = (indiceActual + delta + resultados.count) % resultados.count
        navegarA(indiceActual)
    }

    private func navegarA(_ indice: Int) {
        let sel = resultados[indice]
        pdfView?.setCurrentSelection(sel, animate: true)
        pdfView?.scrollSelectionToVisible(nil)
    }
}

// MARK: - PDF wrapper

struct PDFKitView: UIViewRepresentable {
    let documento: PDFDocument
    let onViewCreated: (PDFView) -> Void

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.document = documento
        onViewCreated(view)
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
