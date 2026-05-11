//
//  Item.swift
//  GES
//
//  Created by Felipe Álvarez on 11-05-26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
