import AppIntents
import CoreSpotlight

// MARK: - Entidad: Problema de Salud GES

/// Representa un Problema de Salud GES ante el sistema (Siri, Atajos, Spotlight).
/// Es un valor liviano espejo de `ProblemaGES`; la fuente de datos sigue siendo
/// `ProblemaGES.todos`.
struct ProblemaGESEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: "Problema de Salud GES",
        numericFormat: "\(placeholder: .int) problemas de salud GES"
    )

    static let defaultQuery = ProblemaGESQuery()

    /// Coincide con el número de PS (1...90).
    let id: Int
    let nombre: String
    let categoria: CategoriaGES

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(nombre)",
            subtitle: "PS \(id) · \(categoria.rawValue)",
            image: .init(systemName: categoria.icono)
        )
    }

    init(_ problema: ProblemaGES) {
        self.id = problema.id
        self.nombre = problema.nombre
        self.categoria = problema.categoria
    }

    /// Resuelve el modelo completo desde el catálogo estático.
    var problema: ProblemaGES? {
        ProblemaGES.todos.first { $0.id == id }
    }
}

// MARK: - Consulta de entidades

/// Permite al sistema enumerar, resolver por id y buscar por texto los PS.
/// `EntityStringQuery` habilita el emparejamiento por nombre/número cuando Siri o
/// Atajos reciben texto libre.
struct ProblemaGESQuery: EntityQuery {
    func entities(for identifiers: [Int]) async throws -> [ProblemaGESEntity] {
        await MainActor.run {
            ProblemaGES.todos
                .filter { identifiers.contains($0.id) }
                .map(ProblemaGESEntity.init)
        }
    }

    /// Sugerencias mostradas en el selector de Atajos (todos los PS).
    func suggestedEntities() async throws -> [ProblemaGESEntity] {
        await MainActor.run { ProblemaGES.todos.map(ProblemaGESEntity.init) }
    }
}

extension ProblemaGESQuery: EntityStringQuery {
    func entities(matching string: String) async throws -> [ProblemaGESEntity] {
        let q = string.folding(options: [.caseInsensitive, .diacriticInsensitive],
                               locale: .current)
            .trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }

        return await MainActor.run {
            ProblemaGES.todos.filter { p in
                let texto = "\(p.id) \(p.nombre) \(p.categoria.rawValue)"
                    .folding(options: [.caseInsensitive, .diacriticInsensitive],
                             locale: .current)
                return texto.contains(q)
            }
            .map(ProblemaGESEntity.init)
        }
    }
}

extension ProblemaGESQuery: EnumerableEntityQuery {
    func allEntities() async throws -> [ProblemaGESEntity] {
        await MainActor.run { ProblemaGES.todos.map(ProblemaGESEntity.init) }
    }
}

// MARK: - Indexado en Spotlight

/// Conformar `IndexedEntity` permite que cada PS aparezca como resultado de
/// Spotlight a nivel de sistema una vez donado.
extension ProblemaGESEntity: IndexedEntity {
    var attributeSet: CSSearchableItemAttributeSet {
        let attrs = CSSearchableItemAttributeSet(contentType: .text)
        attrs.title = nombre
        attrs.contentDescription = "PS \(id) · \(categoria.rawValue)"
        attrs.keywords = [String(id), categoria.rawValue, "GES", "AUGE"]
        return attrs
    }
}

// MARK: - AppEnum: Categoría GES

/// Expone las categorías como parámetro seleccionable en Atajos/Siri.
extension CategoriaGES: nonisolated AppEnum {
    nonisolated static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Categoría GES"
    }

    // El extractor de metadatos de AppIntents exige un diccionario literal y
    // exhaustivo (no admite construcción dinámica), por eso se enumeran los 15 casos.
    nonisolated static var caseDisplayRepresentations: [CategoriaGES: DisplayRepresentation] {
        [
            .cardiovascular: DisplayRepresentation(title: "Cardiovascular", image: .init(systemName: "heart.fill")),
            .oncologico: DisplayRepresentation(title: "Oncológico", image: .init(systemName: "cross.case.fill")),
            .respiratorio: DisplayRepresentation(title: "Respiratorio", image: .init(systemName: "lungs.fill")),
            .neurologico: DisplayRepresentation(title: "Neurológico", image: .init(systemName: "brain.head.profile")),
            .saludMental: DisplayRepresentation(title: "Salud Mental", image: .init(systemName: "brain")),
            .endocrinoMetabolico: DisplayRepresentation(title: "Endocrino y Metabólico", image: .init(systemName: "drop.fill")),
            .musculoesqueletico: DisplayRepresentation(title: "Musculoesquelético", image: .init(systemName: "figure.walk")),
            .oftalmologico: DisplayRepresentation(title: "Oftalmológico", image: .init(systemName: "eye.fill")),
            .renalUrologico: DisplayRepresentation(title: "Renal y Urológico", image: .init(systemName: "drop.triangle.fill")),
            .digestivo: DisplayRepresentation(title: "Digestivo", image: .init(systemName: "leaf.fill")),
            .saludOral: DisplayRepresentation(title: "Salud Oral", image: .init(systemName: "face.smiling")),
            .neonatalPediatrico: DisplayRepresentation(title: "Neonatal y Pediátrico", image: .init(systemName: "person.2.fill")),
            .infeccioso: DisplayRepresentation(title: "Infeccioso e Inmunológico", image: .init(systemName: "shield.fill")),
            .traumatismoUrgencias: DisplayRepresentation(title: "Traumatismo y Urgencias", image: .init(systemName: "exclamationmark.triangle.fill")),
            .otros: DisplayRepresentation(title: "Otros", image: .init(systemName: "staroflife.fill")),
        ]
    }
}
