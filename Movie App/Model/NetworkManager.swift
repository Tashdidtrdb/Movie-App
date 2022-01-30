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
    private let apiKey = "07072e3a5e94efff9aa15185aaaae26f"

    let baseURL = "https://api.themoviedb.org/3/"
  
    private let session: URLSession = URLSession(configuration: .default)
        
    func fetchGenres(completion: @escaping (Result<GenreResponse, Error>) -> Void) {
        let url = "\(baseURL)genre/movie/list?api_key=\(apiKey)"
        performRequest(url: url, model: GenreResponse.self, completion: completion)
    }
    
    func fetchMovies(genreId: Int, page: Int, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        let url = "\(baseURL)discover/movie?api_key=\(apiKey)&with_genres=\(genreId)&page=\(page)&sort_by=popularity.desc"
        performRequest(url: url, model: MovieResponse.self, completion: completion)
    }
    
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
    
// MARK: - Delegate Way of generic request (Cannot have request for different data from same controller)

//protocol NetworkManagerDelegate: AnyObject {
//    func networkManger<T>(_ networkManager: NetworkManager, didFetchWithSuccess data: T)
//    func networkManager(_ networkManager: NetworkManager, didFailWithError error: Error)
//}
    
//    func performRequest<T: Decodable>(url: String, model: T.Type) {
//        guard let url = URL(string: url) else {
//            delegate?.networkManager(self, didFailWithError: NetworkError.badURL)
//            return
//        }
//
//        let task = session.dataTask(with: url) { data, response, error in
//            if let error = error {
//                delegate?.networkManager(self, didFailWithError: error)
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse else {
//                delegate?.networkManager(self, didFailWithError: NetworkError.badResponse)
//                return
//            }
//
//            guard (200...299).contains(response.statusCode) else {
//                delegate?.networkManager(self, didFailWithError: NetworkError.badStatusCode)
//                print(response.statusCode)
//                return
//            }
//
//            guard let data = data else {
//                delegate?.networkManager(self, didFailWithError: NetworkError.badData)
//                return
//            }
//
//            guard let dataResponse = try? JSONDecoder().decode(T.self, from: data) else {
//                delegate?.networkManager(self, didFailWithError: NetworkError.couldNotDecode)
//                return
//            }
//
//            delegate?.networkManger(self, didFetchWithSuccess: dataResponse)
//        }
//
//        task.resume()
//    }
}
