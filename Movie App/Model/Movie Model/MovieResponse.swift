//
//  MovieResponse.swift
//  Movie App
//
//  Created by BS198 on 28/1/22.
//

import Foundation

struct MovieResponse: Decodable {
    let page: Int
    var results: [Movie]
    let total_pages: Int
}
