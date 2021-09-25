//
//  WaterReading.swift
//  
//
//  Created by Bill Gestrich on 9/26/21.
//

import Foundation

public struct WaterReading: Codable {
    
    public let value: Int
    public let systemTime: Date
    
    public init(value: Int, systemTime: Date){
        self.value = value
        self.systemTime = systemTime
    }
}
