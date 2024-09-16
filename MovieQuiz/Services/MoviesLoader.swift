//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Денис Кель on 13.09.2024.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL? {
        return URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf")
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        guard let url = mostPopularMoviesUrl else {
            handler(.failure(URLError(.badURL)))
            return
        }

        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    // Попытка декодирования данных
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    
                    // Проверка на наличие ошибки в ответе
                    if mostPopularMovies.hasError || mostPopularMovies.items.isEmpty {
                        let errorMessage = mostPopularMovies.errorMessage.isEmpty ? "Список фильмов пуст." : mostPopularMovies.errorMessage
                        let error = NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        handler(.failure(error))
                    } else {
                        handler(.success(mostPopularMovies))
                    }
                } catch {
                    // Обработка ошибки декодирования
                    handler(.failure(error))
                }
            case .failure(let error):
                // Обработка сетевых ошибок
                handler(.failure(error))
            }
        }
    }
}
