import SwiftUI

private enum OrdenGES: String, CaseIterable, Identifiable {
    case porId = "Número"
    case porNombre = "Nombre"
    case porCategoria = "Categoría"
    var id: String { rawValue }
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var mostrarFavoritos = false
    @State private var mostrarInfo = false
    @State private var resultados: [ProblemaGES] = ProblemaGES.todos
    @State private var favoritosSet: Set<Int> = []
    @AppStorage("favoritos") private var favoritosString = ""
    @State private var guiaAbierta: ProblemaGES?
    @State private var flujogramaAbierto: ProblemaGES?
    @State private var busquedaActiva = false

    // Orden y filtro de categoría se conservan entre lanzamientos.
    @AppStorage("ordenGES") private var sortOrderRaw = OrdenGES.porId.rawValue
    @AppStorage("categoriaFiltro") private var categoriaFiltroRaw = ""

    private var sortOrder: OrdenGES { OrdenGES(rawValue: sortOrderRaw) ?? .porId }
    private var selectedCategoria: CategoriaGES? {
        categoriaFiltroRaw.isEmpty ? nil : CategoriaGES(rawValue: categoriaFiltroRaw)
    }

    private let categoryCounts: [CategoriaGES: Int] = Dictionary(
        grouping: ProblemaGES.todos, by: \.categoria
    ).mapValues(\.count)

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if resultados.isEmpty {
                        ContentUnavailableView(
                            mostrarFavoritos ? "Sin favoritos" : "Sin resultados",
                            systemImage: mostrarFavoritos ? "star.slash" : "magnifyingglass",
                            description: Text(mostrarFavoritos
                                ? "Marca problemas como favoritos para verlos aquí."
                                : "No se encontraron problemas GES con ese criterio.")
                        )
                    } else {
                        ForEach(resultados) { problema in
                            NavigationLink(value: problema) {
                                ProblemaRow(problema: problema, esFavorito: favoritosSet.contains(problema.id))
                            }
                            .contextMenu {
                                let esFav = favoritosSet.contains(problema.id)
                                Button {
                                    toggleFavorito(problema.id)
                                } label: {
                                    Label(esFav ? "Quitar de favoritos" : "Agregar a favoritos",
                                          systemImage: esFav ? "star.slash" : "star")
                                }
                                if problema.archivoGuiaSIGGES != nil {
                                    Button {
                                        guiaAbierta = problema
                                    } label: {
                                        Label("Ver Guía SIGGES", systemImage: "doc.richtext")
                                    }
                                }
                                if problema.flujogramaDerivacion != nil {
                                    Button {
                                        flujogramaAbierto = problema
                                    } label: {
                                        Label("Ver Flujograma", systemImage: "flowchart.fill")
                                    }
                                }
                            }
                            // Deslizar a la derecha (borde inicial): marcar favorito.
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                let esFav = favoritosSet.contains(problema.id)
                                Button {
                                    toggleFavorito(problema.id)
                                } label: {
                                    Label(esFav ? "Quitar" : "Favorito",
                                          systemImage: esFav ? "star.slash" : "star")
                                }
                                .tint(esFav ? .gray : .yellow)
                            }
                            // Deslizar a la izquierda (borde final): guía GES y, a su
                            // derecha, el flujograma de derivación. El primer botón
                            // declarado queda más cerca del borde (más a la derecha).
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if problema.flujogramaDerivacion != nil {
                                    Button {
                                        flujogramaAbierto = problema
                                    } label: {
                                        Label("Flujograma", systemImage: "flowchart.fill")
                                    }
                                    .tint(.indigo)
                                }
                                if problema.archivoGuiaSIGGES != nil {
                                    Button {
                                        guiaAbierta = problema
                                    } label: {
                                        Label("Guía", systemImage: "doc.richtext")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                        .sheet(item: $guiaAbierta) { problema in
                            if let archivo = problema.archivoGuiaSIGGES {
                                GuiaSIGGESView(nombreArchivo: archivo, problema: problema)
                            }
                        }
                        .sheet(item: $flujogramaAbierto) { problema in
                            if let flujograma = problema.flujogramaDerivacion {
                                FlujogramaZoomView(nombreImagen: flujograma, titulo: problema.nombre)
                            }
                        }
                    }
                }
                .listSectionSeparator(.hidden, edges: .top)
            }
            .listStyle(.plain)
            .navigationDestination(for: ProblemaGES.self) { problema in
                DetalleGESView(problema: problema)
            }
            .searchable(text: $searchText, isPresented: $busquedaActiva, prompt: "Buscar por nombre o número...")
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                favoritosSet = favoritosString.asFavoritosSet()
                aplicarFiltros()
                // Arranque frío vía quick action
                if let accion = AppDelegate.accionPendiente {
                    AppDelegate.accionPendiente = nil
                    ejecutar(accion)
                }
            }
            .onChange(of: favoritosString) { _, new in
                favoritosSet = new.asFavoritosSet()
                aplicarFiltros()
            }
            .onChange(of: categoriaFiltroRaw) { _, _ in aplicarFiltros() }
            .onChange(of: mostrarFavoritos)   { _, _ in aplicarFiltros() }
            .onChange(of: sortOrderRaw)       { _, _ in aplicarFiltros() }
            .task(id: searchText) {
                if searchText.isEmpty { aplicarFiltros(); return }
                try? await Task.sleep(for: .milliseconds(200))
                aplicarFiltros()
            }
            .sheet(isPresented: $mostrarInfo) { InfoView() }
            // App ya en ejecución (warm): el SceneDelegate emite estas notificaciones.
            .onReceive(NotificationCenter.default.publisher(for: .abrirFavoritos)) { _ in
                ejecutar(.favoritos)
            }
            .onReceive(NotificationCenter.default.publisher(for: .enfocarBusqueda)) { _ in
                ejecutar(.buscar)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { mostrarInfo = true } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                    }
                    .accessibilityLabel("Acerca de esta app")
                    .accessibilityInputLabels(["Información", "Acerca de"])
                }
                ToolbarItem(placement: .principal) {
                    Image("GESLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .accessibilityLabel("GES")
                        .accessibilityAddTraits(.isHeader)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { mostrarFavoritos.toggle() }
                    } label: {
                        Image(systemName: mostrarFavoritos ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundColor(mostrarFavoritos ? .yellow : .primary)
                    }
                    .accessibilityLabel("Mostrar solo favoritos")
                    .accessibilityValue(mostrarFavoritos ? "Activado" : "Desactivado")
                    .accessibilityAddTraits(mostrarFavoritos ? .isSelected : [])
                    .accessibilityInputLabels(["Favoritos", "Mostrar favoritos"])
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section("Ordenar por:") {
                            ForEach(OrdenGES.allCases) { orden in
                                Button {
                                    sortOrderRaw = orden.rawValue
                                } label: {
                                    Label {
                                        Text(orden.rawValue)
                                    } icon: {
                                        Image(systemName: sortOrder == orden ? "checkmark" : sortIcon(orden))
                                    }
                                }
                            }
                        }

                        Section("Filtrar por categoría") {
                            if selectedCategoria != nil {
                                Button(role: .destructive) {
                                    categoriaFiltroRaw = ""
                                } label: {
                                    Label("Todas las categorías", systemImage: "xmark.circle")
                                }
                            }
                            ForEach(CategoriaGES.allCases) { cat in
                                Button {
                                    categoriaFiltroRaw = selectedCategoria == cat ? "" : cat.rawValue
                                } label: {
                                    Label {
                                        Text("\(cat.rawValue) (\(categoryCounts[cat] ?? 0))")
                                    } icon: {
                                        Image(systemName: selectedCategoria == cat ? "checkmark" : cat.icono)
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.title3)
                            .foregroundColor(selectedCategoria.map { $0.color } ?? .primary)
                    }
                    .accessibilityLabel("Ordenar y filtrar")
                    .accessibilityValue(selectedCategoria.map { "Filtrado por \($0.rawValue)" } ?? "Sin filtro de categoría")
                    .accessibilityInputLabels(["Ordenar", "Filtrar", "Ordenar y filtrar"])
                }
            }
        }
    }

    private func toggleFavorito(_ id: Int) {
        var set = favoritosString.asFavoritosSet()
        if set.contains(id) { set.remove(id) } else { set.insert(id) }
        favoritosString = set.sorted().map(String.init).joined(separator: ",")
    }

    /// Ejecuta un quick action del ícono de la app.
    private func ejecutar(_ accion: QuickAction) {
        switch accion {
        case .favoritos:
            busquedaActiva = false
            withAnimation { mostrarFavoritos = true }
        case .buscar:
            mostrarFavoritos = false
            categoriaFiltroRaw = ""
            activarBusqueda()
        }
    }

    /// Activa la barra de búsqueda. En arranque frío el `.searchable` puede no
    /// estar instalado aún cuando se consume el quick action, y un único retardo
    /// fijo es frágil (demasiado pronto en dispositivos lentos, innecesariamente
    /// tardío en los rápidos). Re-afirmamos la activación en varios instantes
    /// dentro de una ventana corta: la primera que ocurra tras instalarse el
    /// `.searchable` gana, y las posteriores son no-ops idempotentes.
    private func activarBusqueda() {
        guard !busquedaActiva else { return }
        for retardo in [0.1, 0.35, 0.6] {
            DispatchQueue.main.asyncAfter(deadline: .now() + retardo) {
                busquedaActiva = true
            }
        }
    }

    private func sortIcon(_ orden: OrdenGES) -> String {
        switch orden {
        case .porId: "number"
        case .porNombre: "textformat.abc"
        case .porCategoria: "tag"
        }
    }

    private func aplicarFiltros() {
        let query = searchText
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespaces)
        let categoria = selectedCategoria
        let soloFavoritos = mostrarFavoritos
        let favs = favoritosSet

        var filtered = ProblemaGES.todos.filter { p in
            if soloFavoritos, !favs.contains(p.id) { return false }
            if let cat = categoria, p.categoria != cat { return false }
            if !query.isEmpty {
                let texto = "\(p.id) \(p.nombre) \(p.descripcion) \(p.poblacionObjetivo)"
                    .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                return texto.contains(query)
            }
            return true
        }

        switch sortOrder {
        case .porId: break
        case .porNombre: filtered.sort { $0.nombre < $1.nombre }
        case .porCategoria: filtered.sort { $0.categoria.rawValue < $1.categoria.rawValue }
        }

        resultados = filtered
    }
}

private struct ProblemaRow: View {
    let problema: ProblemaGES
    let esFavorito: Bool

    @ScaledMetric(relativeTo: .title3) private var circuloSize: CGFloat = 46

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(problema.categoria.color.opacity(0.15))
                    .frame(width: circuloSize, height: circuloSize)
                Text("\(problema.id)")
                    .font(.system(.title3, design: .serif, weight: .bold))
                    .foregroundColor(problema.categoria.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(problema.nombre)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    if esFavorito {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: problema.categoria.icono)
                        .font(.caption2)
                    Text(problema.categoria.rawValue)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Problema \(problema.id). \(problema.nombre). \(problema.categoria.rawValue)."
            + (esFavorito ? " Favorito." : "")
        )
        // Control por Voz: alias cortos para "tocar" la fila sin decir el label completo.
        .accessibilityInputLabels([
            problema.nombre,
            "Problema \(problema.id)",
            "\(problema.id)"
        ])
    }
}


#Preview("Light") { ContentView() }
#Preview("Dark") { ContentView().preferredColorScheme(.dark) }
