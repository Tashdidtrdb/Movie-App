//
//  NetworkManager.swift
//  Movie App
//
//  Created by BS198 on 28/1/22.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case badResponse
    case badStatusCode
    case badData
    case couldNotDecode
}

struct NetworkManager {
  
    private let session: URLSession = URLSession(configuration: .default)
    
    func performRequest<T: Decodable>(url: String, model: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.badResponse))
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                completion(.failure(NetworkError.badStatusCode))
                print(response.statusCode)
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.badData))
                return
            }
            
            guard let dataResponse = try? JSONDecoder().decode(T.self, from: data) else {
                completion(.failure(NetworkError.couldNotDecode))
                return
            }
            
            completion(.success(dataResponse))
        }
        
        task.resume()
    }
}
