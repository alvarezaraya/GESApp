import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var selectedCategoria: CategoriaGES?
    @State private var mostrarFavoritos = false
    @State private var mostrarInfo = false
    @State private var resultados: [ProblemaGES] = ProblemaGES.todos
    @State private var favoritosSet: Set<Int> = []
    // Índice precalculado: id → string unificada y en minúsculas para búsqueda rápida
    @State private var searchIndex: [Int: String] = [:]
    @AppStorage("favoritos") private var favoritosString = ""

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
                            NavigationLink(value: problema.id) {
                                ProblemaRow(problema: problema, esFavorito: favoritosSet.contains(problema.id))
                            }
                        }
                    }
                }
                .listSectionSeparator(.hidden, edges: .top)
            }
            .listStyle(.plain)
            .navigationDestination(for: Int.self) { id in
                if let problema = ProblemaGES.todos.first(where: { $0.id == id }) {
                    DetalleGESView(problema: problema, favoritosString: $favoritosString)
                }
            }
            .searchable(text: $searchText, prompt: "Buscar por nombre o número...")
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                favoritosSet = Self.parseFavoritos(favoritosString)
                preconstruirIndice()
            }
            .onChange(of: favoritosString) { _, new in
                favoritosSet = Self.parseFavoritos(new)
                aplicarFiltros()
            }
            .onChange(of: selectedCategoria) { _, _ in aplicarFiltros() }
            .onChange(of: mostrarFavoritos)   { _, _ in aplicarFiltros() }
            // Debounce: espera 200 ms tras el último carácter antes de filtrar
            .task(id: searchText) {
                if searchText.isEmpty { aplicarFiltros(); return }
                try? await Task.sleep(for: .milliseconds(200))
                aplicarFiltros()
            }
            .sheet(isPresented: $mostrarInfo) { InfoView() }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { mostrarInfo = true } label: {
                        Image(systemName: "info.circle").imageScale(.large)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Image("GESLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        if selectedCategoria != nil {
                            Button(role: .destructive) {
                                selectedCategoria = nil
                            } label: {
                                Label("Todas las categorías", systemImage: "xmark.circle")
                            }
                            Divider()
                        }
                        ForEach(CategoriaGES.allCases) { cat in
                            Button {
                                selectedCategoria = selectedCategoria == cat ? nil : cat
                            } label: {
                                Label {
                                    Text(cat.rawValue)
                                } icon: {
                                    Image(systemName: selectedCategoria == cat ? "checkmark" : cat.icono)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: selectedCategoria != nil
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                            .imageScale(.large)
                            .foregroundColor(selectedCategoria.map { $0.color } ?? .primary)
                    }

                    Button {
                        withAnimation { mostrarFavoritos.toggle() }
                    } label: {
                        Image(systemName: mostrarFavoritos ? "star.fill" : "star")
                            .imageScale(.large)
                            .foregroundColor(mostrarFavoritos ? .yellow : .primary)
                    }
                }
            }
        }
    }

    // Construye el índice una sola vez en background al lanzar la app
    private func preconstruirIndice() {
        guard searchIndex.isEmpty else { return }
        let todos = ProblemaGES.todos
        Task.detached(priority: .background) {
            var idx: [Int: String] = [:]
            idx.reserveCapacity(todos.count)
            for p in todos {
                idx[p.id] = "\(p.id) \(p.nombre) \(p.descripcion) \(p.poblacionObjetivo)".lowercased()
            }
            let result = idx
            await MainActor.run { searchIndex = result }
        }
    }

    // Filtrado síncrono en main thread — 90 items es trivial; evita overhead de dispatch
    private func aplicarFiltros() {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        let categoria = selectedCategoria
        let soloFavoritos = mostrarFavoritos
        let favs = favoritosSet
        let idx = searchIndex
        let todos = ProblemaGES.todos

        resultados = todos.filter { p in
            if soloFavoritos, !favs.contains(p.id) { return false }
            if let cat = categoria, p.categoria != cat { return false }
            if !query.isEmpty {
                if idx.isEmpty {
                    // Índice aún no listo: fallback directo
                    return p.nombre.lowercased().contains(query)
                        || p.descripcion.lowercased().contains(query)
                        || p.poblacionObjetivo.lowercased().contains(query)
                        || String(p.id) == query
                }
                return idx[p.id]?.contains(query) == true
            }
            return true
        }
    }

    private static func parseFavoritos(_ string: String) -> Set<Int> {
        Set(string.split(separator: ",").compactMap { Int($0) })
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
