//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Денис Кель on 08.09.2024.
//

import Foundation


protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}

