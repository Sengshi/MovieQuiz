//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Денис Кель on 08.09.2024.
//

import Foundation


struct GameResult {
    let correct: Int
    let total: Int
    let date: Date

    // метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
