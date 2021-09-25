//
//  DynamoStoreService.swift
//
//
//  Created by Bill Gestrich on 11/8/20.
//

import Foundation
import NIO
import DynamoDB
import WaterMonitorClient

public struct DynamoStoreService {
    
    public static let partitionKey = "partitionKey"
    public static let sortKey = "sort"
    
    let db: DynamoDB
    let tableName: String
    
    
    //General
    
    public init(db: DynamoDB = DynamoDB(region: Region.useast1), tableName: String) {
        self.db = db
        self.tableName = tableName
    }
    
    public func getItems(partition: String, startSort: String, endSort: String) -> EventLoopFuture<DynamoDB.QueryOutput> {
        
        return db.query(.init(
            expressionAttributeNames: ["#u" : DynamoStoreService.partitionKey],
            expressionAttributeValues: [":u": .init(s: partition), ":d1" : .init(s: startSort), ":d2" : .init(s: endSort)],
            keyConditionExpression: "#u = :u AND \(DynamoStoreService.sortKey) BETWEEN :d1 AND :d2",
            tableName: tableName
        ))
    }
    
    
    //MARK: WaterReading
    
    public func storeReading(_ reading: WaterReading) -> EventLoopFuture<WaterReading> {

        let input = DynamoDB.PutItemInput(item: reading.attributeValues, tableName: tableName)
        return db.putItem(input).map { (_) -> WaterReading in
            reading
        }
    }
    
    public func getWaterReadingsSinceDate(oldestDate: Date, latestDate: Date) -> EventLoopFuture<[WaterReading]> {
        
        let oldestDateAsString = Utils.iso8601Formatter.string(from: oldestDate)
        let currentDateAsString = Utils.iso8601Formatter.string(from: latestDate)
        
        return getItems(partition: WaterReading.partitionValue, startSort: oldestDateAsString, endSort: currentDateAsString).map { (output) -> [WaterReading] in
            let waterReadingValues = output.items?.compactMap({ (dict) -> WaterReading? in
                return WaterReading.waterReadingWith(dictionary: dict)
            }) ?? []
            
            return waterReadingValues
        }
    }
    
    public func getWaterReadingsInPastMinutes(_ minutes: Int, referenceDate: Date) -> EventLoopFuture<[WaterReading]> {
        let interval = TimeInterval(minutes) * -60
        let date = referenceDate.addingTimeInterval(interval)
        return self.getWaterReadingsSinceDate(oldestDate: date, latestDate: referenceDate)
    }
    
    public func getLatestWaterReading() -> EventLoopFuture<WaterReading?> {
        self.getWaterReadingsInPastMinutes(60, referenceDate: Date()).map { (readings) -> WaterReading? in
            return readings.last
        }
    }
    
}
