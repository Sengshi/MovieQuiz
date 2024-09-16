//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Денис Кель on 13.09.2024.
//

import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
    
    // Проверка на наличие ошибки
    var hasError: Bool {
        return !errorMessage.isEmpty
    }
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
