//
//  WaterReading+Dynamo.swift
//
//
//  Created by Bill Gestrich on 11/7/20.
//

import Foundation
import DynamoDB
import WaterMonitorClient

extension WaterReading{
    
    public static let partitionKey = DynamoStoreService.partitionKey
    public static let partitionValue: String = "WaterReading"
    public static let systemTimeKey = DynamoStoreService.sortKey
    public static let valueKey = "value"
    
    public var attributeValues: [String: DynamoDB.AttributeValue] {
        var dictionary = [
            WaterReading.partitionKey: DynamoDB.AttributeValue(s: String(WaterReading.partitionValue)),
            WaterReading.valueKey: DynamoDB.AttributeValue(n: String(value)),
        ]
        
        dictionary[WaterReading.systemTimeKey] = DynamoDB.AttributeValue(s: Utils.iso8601Formatter.string(from: systemTime))
        
        return dictionary
    }

    public static func waterReadingWith(dictionary: [String: DynamoDB.AttributeValue]) -> WaterReading? {
        
        guard let systemTimeString = dictionary[WaterReading.systemTimeKey]?.s, let systemTime = Utils.iso8601Formatter.date(from: systemTimeString) else {
            return nil
        }
        
        guard let valueString = dictionary[WaterReading.valueKey]?.n, let value = Int(valueString) else {
            return nil
        }
        
        return WaterReading(value: value, systemTime: systemTime)
    }
}

