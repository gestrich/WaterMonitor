//
//  WaterReadingsClient.swift
//  
//
//  Created by Bill Gestrich on 9/26/21.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class WaterMonitorClient {

    public let urlString: String
    
    public enum WaterFetchError: LocalizedError {
        case genericError(String)
    }
    
    public init(urlString: String) {
        self.urlString = urlString
    }
    
    public func fetchLatestReadings(completion: @escaping (Result<[WaterReading], Error>) -> Void) {

        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(WaterFetchError.genericError("No Data")))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    let readings = try decoder.decode([WaterReading].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(readings))
                    }
                } catch {
                    completion(.failure(WaterFetchError.genericError("Error Decoding: \(error)")))
                }
            }
            
            urlSession.resume()
        }
    }
}
