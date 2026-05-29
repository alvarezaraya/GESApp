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
    case primaria = "Confirmación en APS"
    case secundaria = "SIC de derivación simple"
    case urgencias = "Ingreso por Urgencia"
    case ambos = "Mixto"
    case cualquierNivel = "Ingresa en cualquier nivel"
    case derivaSecundaria = "SIC con sospecha GES"

    var icono: String {
        switch self {
        case .primaria: "house.fill"
        case .secundaria: "building.2.fill"
        case .urgencias: "cross.fill"
        case .ambos: "arrow.triangle.branch"
        case .cualquierNivel: "point.3.connected.trianglepath.dotted"
        case .derivaSecundaria: "arrowshape.turn.up.right.fill"
        }
    }

    var color: Color {
        switch self {
        case .primaria: .green
        case .secundaria: .blue
        case .urgencias: .red
        case .ambos: .orange
        case .cualquierNivel: .purple
        case .derivaSecundaria: .indigo
        }
    }

    var procesoGES: String {
        switch self {
        case .primaria:
            return "La confirmación diagnóstica GES se realiza en Atención Primaria (APS/CESFAM). El profesional de cabecera genera la notificación GES y coordina el tratamiento en el nivel primario. Se deriva a nivel secundario solo ante complicaciones o refractariedad terapéutica."
        case .secundaria:
            return "La confirmación diagnóstica GES se realiza en el nivel secundario (médico especialista). APS puede detectar la sospecha y emitir la derivación, pero la notificación GES y la activación de garantías ocurren cuando el especialista confirma el diagnóstico."
        case .urgencias:
            return "El caso GES se confirma y notifica directamente en el Servicio de Urgencia, sin requerir derivación previa desde APS. La garantía de oportunidad aplica desde el momento de la atención de urgencia."
        case .ambos:
            return "La confirmación diagnóstica GES puede ocurrir en APS (para casos detectados en tamizaje o consulta ambulatoria) o en el nivel secundario (para casos derivados o de mayor complejidad), según la vía de ingreso del paciente."
        case .cualquierNivel:
            return "El caso GES puede iniciarse en cualquier nivel de la red asistencial: en el Servicio de Urgencia ante una descompensación o presentación aguda (la garantía GES se activa desde la atención de urgencia), en Atención Primaria (APS/CESFAM) durante una consulta ambulatoria de morbilidad, o en el nivel secundario durante una consulta de especialidad o un período de hospitalización por otro problema de salud."
        case .derivaSecundaria:
            return "El caso GES se abre desde la sospecha en Atención Primaria (APS/CESFAM): el médico emite una Solicitud de Interconsulta (SIC) que registra la sospecha en SIGGES e inicia la garantía de oportunidad de diagnóstico. La confirmación diagnóstica y el tratamiento se realizan siempre en el nivel secundario (médico especialista). La derivación al especialista es obligatoria en todos los casos."
        }
    }
}

enum EstadoDS29 {
    case vigente
    case modificado   // cambiado en DS N°29 (dic. 2025)
    case nuevo        // incorporado en DS N°29 (dic. 2025)
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
    var estadoDS29: EstadoDS29 = .vigente
}
