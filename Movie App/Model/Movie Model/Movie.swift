//
//  Movie.swift
//  Movie App
//
//  Created by BS198 on 28/1/22.
//

import Foundation

struct Movie: Decodable {
    let id: Int
    let original_title: String
    let poster_path: String?
    
    var posterURL: String {
        return "https://image.tmdb.org/t/p/w200\(poster_path ?? "nil")"
    }
}
