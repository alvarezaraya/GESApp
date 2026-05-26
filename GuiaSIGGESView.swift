import SwiftUI
import PDFKit

struct GuiaSIGGESView: View {
    let nombreArchivo: String
    let problema: ProblemaGES

    var body: some View {
        NavigationStack {
            PDFKitView(nombreArchivo: nombreArchivo)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Guía SIGGES — GES #\(problema.id)")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let nombreArchivo: String

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        if let url = Bundle.main.url(forResource: nombreArchivo,
                                     withExtension: nil,
                                     subdirectory: "Guias Rapidas SIGGES"),
           let doc = PDFDocument(url: url) {
            view.document = doc
        }
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
