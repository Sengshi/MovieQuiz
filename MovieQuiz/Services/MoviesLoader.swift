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
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }

    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        let url = mostPopularMoviesUrl

        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    
                    if mostPopularMovies.hasError || mostPopularMovies.items.isEmpty {
                        let errorMessage = mostPopularMovies.errorMessage.isEmpty ? "Список фильмов пуст." : mostPopularMovies.errorMessage
                        let error = NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        handler(.failure(error))
                    } else {
                        handler(.success(mostPopularMovies))
                    }
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                // Обработка сетевых ошибок
                handler(.failure(error))
            }
        }
    }
}
