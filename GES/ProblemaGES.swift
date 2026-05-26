import SwiftUI

enum CategoriaGES: String, CaseIterable, Identifiable {
    case cardiovascular = "Cardiovascular"
    case oncologico = "Oncológico"
    case respiratorio = "Respiratorio"
    case neurologico = "Neurológico"
    case saludMental = "Salud Mental"
    case endocrinoMetabolico = "Endocrino y Metabólico"
    case musculoesqueletico = "Musculoesquelético"
    case oftalmologico = "Oftalmológico"
    case renalUrologico = "Renal y Urológico"
    case digestivo = "Digestivo"
    case saludOral = "Salud Oral"
    case neonatalPediatrico = "Neonatal y Pediátrico"
    case infeccioso = "Infeccioso e Inmunológico"
    case traumatismoUrgencias = "Traumatismo y Urgencias"
    case otros = "Otros"

    var id: String { rawValue }

    var icono: String {
        switch self {
        case .cardiovascular: "heart.fill"
        case .oncologico: "cross.case.fill"
        case .respiratorio: "lungs.fill"
        case .neurologico: "brain.head.profile"
        case .saludMental: "brain"
        case .endocrinoMetabolico: "drop.fill"
        case .musculoesqueletico: "figure.walk"
        case .oftalmologico: "eye.fill"
        case .renalUrologico: "drop.triangle.fill"
        case .digestivo: "leaf.fill"
        case .saludOral: "face.smiling"
        case .neonatalPediatrico: "person.2.fill"
        case .infeccioso: "shield.fill"
        case .traumatismoUrgencias: "exclamationmark.triangle.fill"
        case .otros: "staroflife.fill"
        }
    }

    var color: Color {
        switch self {
        case .cardiovascular: .red
        case .oncologico: .purple
        case .respiratorio: .cyan
        case .neurologico: .indigo
        case .saludMental: .teal
        case .endocrinoMetabolico: .orange
        case .musculoesqueletico: .brown
        case .oftalmologico: .blue
        case .renalUrologico: .yellow
        case .digestivo: .green
        case .saludOral: .mint
        case .neonatalPediatrico: .pink
        case .infeccioso: Color(red: 0.7, green: 0.15, blue: 0.15)
        case .traumatismoUrgencias: Color(red: 0.9, green: 0.35, blue: 0.1)
        case .otros: .gray
        }
    }
}

enum NivelIngresoGES: String {
    case primaria = "Ingresa en APS"
    case secundaria = "Se deriva a nivel secundario"
    case urgencias = "Ingresa por Urgencia"
    case ambos = "Se ingresa a nivel primario o secundario"

    var icono: String {
        switch self {
        case .primaria: "house.fill"
        case .secundaria: "building.2.fill"
        case .urgencias: "cross.fill"
        case .ambos: "arrow.triangle.branch"
        }
    }

    var color: Color {
        switch self {
        case .primaria: .green
        case .secundaria: .blue
        case .urgencias: .red
        case .ambos: .orange
        }
    }

    var procesoGES: String {
        switch self {
        case .primaria:
            return "La sospecha GES se registra en APS (SIGGES). Si el diagnóstico se confirma en el nivel primario, el profesional de cabecera genera la notificación GES y gestiona el tratamiento sin necesidad de derivación. Se deriva a nivel secundario solo ante complicaciones o refractariedad terapéutica."
        case .secundaria:
            return "El profesional de APS registra la sospecha GES (SIGGES) y genera la derivación al especialista de nivel secundario. La confirmación diagnóstica, la notificación GES y la activación de la garantía de tratamiento ocurren en el nivel secundario, donde se coordina el tratamiento."
        case .urgencias:
            return "Ingreso directo por el servicio de urgencias hospitalario. La sospecha y notificación GES se registran en ese nivel, sin requerir derivación previa desde APS. La garantía de oportunidad aplica desde el momento de la atención de urgencia."
        case .ambos:
            return "La sospecha GES puede activarse en APS (tamizaje o detección temprana) o registrarse directamente en nivel secundario según la vía de consulta. APS confirma y trata los casos de menor complejidad; deriva a especialista cuando el diagnóstico o tratamiento requieren nivel secundario."
        }
    }
}

struct ProblemaGES: Identifiable {
    let id: Int
    let nombre: String
    let categoria: CategoriaGES
    let nivelIngreso: NivelIngresoGES
    let descripcion: String
    let poblacionObjetivo: String
    let sospechaDiagnostica: String
    let confirmacionDiagnostica: String
    let garantiaOportunidad: String
    let tratamiento: String
    let seguimiento: String
    var archivoGuiaSIGGES: String? = nil
}
