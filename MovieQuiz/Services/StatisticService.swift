//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Денис Кель on 08.09.2024.
//

import Foundation


final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    enum UserDefaultsKeys: String {
        case bestGameCorrect = "bestGameCorrect"
        case bestGameTotal = "bestGameTotal"
        case bestGameDate = "bestGameDate"
        case totalCorrectAnswers = "totalCorrectAnswers"
        case totalQuestions = "totalQuestions"
        case gamesCount = "gamesCount"
    }
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: UserDefaultsKeys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: UserDefaultsKeys.gamesCount.rawValue)
        }
    }

    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: UserDefaultsKeys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: UserDefaultsKeys.bestGameTotal.rawValue)
            let dateInterval = storage.double(forKey: UserDefaultsKeys.bestGameDate.rawValue)
            let date = Date(timeIntervalSince1970: dateInterval)
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: UserDefaultsKeys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: UserDefaultsKeys.bestGameTotal.rawValue)
            storage.set(newValue.date.timeIntervalSince1970, forKey: UserDefaultsKeys.bestGameDate.rawValue)
        }
    }

    
    var totalAccuracy: Double {
        let totalCorrectAnswers = storage.integer(forKey: UserDefaultsKeys.totalCorrectAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: UserDefaultsKeys.totalQuestions.rawValue)
        
        guard totalQuestions > 0 else {
            return 0.0
        }
        
        return (Double(totalCorrectAnswers) * 100) / Double(totalQuestions)
    }
    
    func store(correct count: Int, total amount: Int) {
        let totalCorrectAnswers = storage.integer(forKey: UserDefaultsKeys.totalCorrectAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: UserDefaultsKeys.totalQuestions.rawValue)
        
        storage.set(totalCorrectAnswers + count, forKey: UserDefaultsKeys.totalCorrectAnswers.rawValue)
        storage.set(totalQuestions + amount, forKey: UserDefaultsKeys.totalQuestions.rawValue)
        
        gamesCount += 1
        
        let currentGameResult = GameResult(correct: count, total: amount, date: Date())
        if currentGameResult.isBetterThan(bestGame) {
            bestGame = currentGameResult
        }
    }
    
    
}

