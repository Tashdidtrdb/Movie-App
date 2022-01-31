//
//  MovieServer.swift
//  Movie App
//
//  Created by BS198 on 31/1/22.
//

import Foundation

struct MovieServer {
    private let apiKey = "07072e3a5e94efff9aa15185aaaae26f"

    let baseURL = "https://api.themoviedb.org/3/"
    
    let networkManager = NetworkManager()
    
    func fetchGenres(completion: @escaping (Result<GenreResponse, Error>) -> Void) {
        let url = "\(baseURL)genre/movie/list?api_key=\(apiKey)"
        networkManager.performRequest(url: url, model: GenreResponse.self, completion: completion)
    }
    
    func fetchMovies(genreId: Int, page: Int, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        let url = "\(baseURL)discover/movie?api_key=\(apiKey)&with_genres=\(genreId)&page=\(page)&sort_by=popularity.desc"
        networkManager.performRequest(url: url, model: MovieResponse.self, completion: completion)
    }
}
