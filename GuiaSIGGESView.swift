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
        if let bundleURL = Bundle.main.resourceURL {
            let fileURL = bundleURL.appendingPathComponent(nombreArchivo)
            if let doc = PDFDocument(url: fileURL) {
                view.document = doc
            }
        }
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
