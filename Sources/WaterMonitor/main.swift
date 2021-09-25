import NIO
import AWSLambdaRuntime
import AWSLambdaEvents
import Foundation
import WaterMonitorClient

public enum ExampleError: Error {
    case genericError (String)
}

Lambda.run(Handler())

public struct Handler: EventLoopLambdaHandler {
    
    public typealias In = APIGateway.Request
    public typealias Out = APIGateway.Response
    
    let dynamoStore = DynamoStoreService(tableName: "WaterMonitor")
    
    public init(){
        
    }
    
    public func handle(context: Lambda.Context, event: APIGateway.Request) -> EventLoopFuture<APIGateway.Response> {
        
        //Path example "/Prod/waterReading"
        let path = event.requestContext.path.split(separator: "/").last
        
        if path == "waterReading" && event.httpMethod == .POST {
            guard let data = event.body?.data(using: .utf8) else {
                let resp = APIGateway.Response(statusCode: .badRequest, headers: ["Content-Type": "application/json"], body: jsonString(from: ["result": "No body data"]))
                return context.eventLoop.makeSucceededFuture(resp)
            }
            
            do {
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
                decoder.dateDecodingStrategy = .formatted(formatter)
                let reading = try decoder.decode(WaterReading.self, from: data)
                
                return dynamoStore.storeReading(reading).flatMap { reading in
                    let resp = APIGateway.Response(statusCode: .ok, headers: ["Content-Type": "application/json"], body: jsonString(from: ["result": "Reading added"]))
                    return context.eventLoop.makeSucceededFuture(resp)
                }
            } catch {
                let errorMessage = "Can't convert data to WaterReading: \(error)"
                let resp = APIGateway.Response(statusCode: .badRequest, headers: ["Content-Type": "application/json"], body: jsonString(from: ["result": errorMessage]))
                return context.eventLoop.makeSucceededFuture(resp)
            }
            
        } else if path == "waterReading"  && event.httpMethod == .GET {
            return dynamoStore.getWaterReadingsInPastMinutes(60 * 24, referenceDate: Date()).flatMap { readings in
                
                do {
                    let encoder = JSONEncoder()
                    encoder.dateEncodingStrategy = .formatted(Utils.iso8601Formatter)
                    let jsonData = try encoder.encode(readings)
                    
                    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                        let resp = APIGateway.Response(statusCode: .badRequest, headers: ["Content-Type": "application/json"], body: jsonString(from: ["result": "Cannot convert data to string"]))
                        return context.eventLoop.makeSucceededFuture(resp)
                    }
                    
                    let resp = APIGateway.Response(statusCode: .ok, headers: ["Content-Type": "application/json"], body: jsonString)
                    return context.eventLoop.makeSucceededFuture(resp)
                    
                } catch {
                    let resp = APIGateway.Response(statusCode: .badRequest, headers: ["Content-Type": "application/json"], body: jsonString(from: ["result": "Cannot convert reading to data"]))
                    return context.eventLoop.makeSucceededFuture(resp)
                }
                

            }
        } else {
            let resp = APIGateway.Response(statusCode: .ok, headers: ["Content-Type": "application/json"], body: jsonString(from: ["result": "Unknown path: \(path ?? "")"]))
            return context.eventLoop.makeSucceededFuture(resp)
        }  
    }
    
    func jsonString(from: [String: String]) -> String? {
        let data = try! JSONSerialization.data(withJSONObject: from, options: [])
        let jsonString = String(data: data, encoding: .utf8)
        return jsonString
    }
}
