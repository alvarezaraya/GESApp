import SwiftUI

private enum OrdenGES: String, CaseIterable, Identifiable {
    case porId = "Número"
    case porNombre = "Nombre"
    case porCategoria = "Categoría"
    var id: String { rawValue }
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedCategoria: CategoriaGES?
    @State private var mostrarFavoritos = false
    @State private var mostrarInfo = false
    @State private var sortOrder: OrdenGES = .porId
    @State private var resultados: [ProblemaGES] = ProblemaGES.todos
    @State private var favoritosSet: Set<Int> = []
    @AppStorage("favoritos") private var favoritosString = ""

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
                        }
                    }
                }
                .listSectionSeparator(.hidden, edges: .top)
            }
            .listStyle(.plain)
            .navigationDestination(for: ProblemaGES.self) { problema in
                DetalleGESView(problema: problema)
            }
            .searchable(text: $searchText, prompt: "Buscar por nombre o número...")
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                favoritosSet = favoritosString.asFavoritosSet()
                aplicarFiltros()
            }
            .onChange(of: favoritosString) { _, new in
                favoritosSet = new.asFavoritosSet()
                aplicarFiltros()
            }
            .onChange(of: selectedCategoria) { _, _ in aplicarFiltros() }
            .onChange(of: mostrarFavoritos)   { _, _ in aplicarFiltros() }
            .onChange(of: sortOrder)          { _, _ in aplicarFiltros() }
            .task(id: searchText) {
                if searchText.isEmpty { aplicarFiltros(); return }
                try? await Task.sleep(for: .milliseconds(200))
                aplicarFiltros()
            }
            .sheet(isPresented: $mostrarInfo) { InfoView() }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { mostrarInfo = true } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Image("GESLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { mostrarFavoritos.toggle() }
                    } label: {
                        Image(systemName: mostrarFavoritos ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundColor(mostrarFavoritos ? .yellow : .primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section("Ordenar por:") {
                            ForEach(OrdenGES.allCases) { orden in
                                Button {
                                    sortOrder = orden
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
                                    selectedCategoria = nil
                                } label: {
                                    Label("Todas las categorías", systemImage: "xmark.circle")
                                }
                            }
                            ForEach(CategoriaGES.allCases) { cat in
                                Button {
                                    selectedCategoria = selectedCategoria == cat ? nil : cat
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
                }
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
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        let categoria = selectedCategoria
        let soloFavoritos = mostrarFavoritos
        let favs = favoritosSet

        var filtered = ProblemaGES.todos.filter { p in
            if soloFavoritos, !favs.contains(p.id) { return false }
            if let cat = categoria, p.categoria != cat { return false }
            if !query.isEmpty {
                let texto = "\(p.id) \(p.nombre) \(p.descripcion) \(p.poblacionObjetivo)".lowercased()
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

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(problema.categoria.color.opacity(0.15))
                    .frame(width: 46, height: 46)
                Text("\(problema.id)")
                    .font(.system(.title3, design: .serif, weight: .bold))
                    .foregroundColor(problema.categoria.color)
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
    }
}

#Preview("Light") { ContentView() }
#Preview("Dark") { ContentView().preferredColorScheme(.dark) }
