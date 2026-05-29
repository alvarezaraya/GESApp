import SwiftUI
import PDFKit

struct GuiaSIGGESView: View {
    let nombreArchivo: String
    let problema: ProblemaGES

    @State private var mostrarMiniaturas = false
    @State private var mostrarBusqueda = false
    @State private var textoBusqueda = ""
    @State private var pdfView: PDFView?
    @State private var resultados: [PDFSelection] = []
    @State private var indiceActual: Int = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .trailing) {
                PDFKitView(nombreArchivo: nombreArchivo, onViewCreated: { pdfView = $0 })
                    .ignoresSafeArea(edges: .bottom)

                if mostrarMiniaturas, let pdfView {
                    ThumbnailSidebarView(pdfView: pdfView)
                        .transition(.move(edge: .trailing))
                }
            }
            .navigationTitle(problema.nombre)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $textoBusqueda, isPresented: $mostrarBusqueda, prompt: "Buscar en guía…")
            .onChange(of: textoBusqueda) { _, query in
                reiniciarBusqueda()
                guard let pdfView, let doc = pdfView.document, !query.isEmpty else { return }
                doc.beginFindString(query, withOptions: .caseInsensitive)
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .PDFDocumentDidFindMatch)
            ) { note in
                guard let sel = note.userInfo?["PDFDocumentFoundSelections"] as? [PDFSelection],
                      let match = sel.first else { return }
                resultados.append(match)
                if resultados.count == 1 { navegarA(0) }
            }
            .safeAreaInset(edge: .bottom) {
                if mostrarBusqueda && !resultados.isEmpty {
                    navBar
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation { mostrarBusqueda.toggle() }
                            if !mostrarBusqueda { reiniciarBusqueda() }
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        Button {
                            withAnimation { mostrarMiniaturas.toggle() }
                        } label: {
                            Image(systemName: mostrarMiniaturas ? "sidebar.right" : "sidebar.squares.right")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Barra de navegación de resultados

    private var navBar: some View {
        HStack(spacing: 20) {
            Button { navegar(delta: -1) } label: {
                Image(systemName: "chevron.up")
            }
            .disabled(resultados.count <= 1)

            Text("\(indiceActual + 1) de \(resultados.count)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)

            Button { navegar(delta: +1) } label: {
                Image(systemName: "chevron.down")
            }
            .disabled(resultados.count <= 1)
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
    let nombreArchivo: String
    let onViewCreated: (PDFView) -> Void

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        if let bundleURL = Bundle.main.resourceURL {
            let fileURL = bundleURL.appendingPathComponent(nombreArchivo)
            if let doc = PDFDocument(url: fileURL) {
                view.document = doc
            }
        }
        onViewCreated(view)
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// MARK: - Thumbnail sidebar

struct ThumbnailSidebarView: UIViewRepresentable {
    let pdfView: PDFView

    func makeUIView(context: Context) -> PDFThumbnailView {
        let thumb = PDFThumbnailView()
        thumb.pdfView = pdfView
        thumb.thumbnailSize = CGSize(width: 80, height: 110)
        thumb.layoutMode = .vertical
        thumb.backgroundColor = UIColor.systemGroupedBackground
        return thumb
    }

    func updateUIView(_ uiView: PDFThumbnailView, context: Context) {}
}
