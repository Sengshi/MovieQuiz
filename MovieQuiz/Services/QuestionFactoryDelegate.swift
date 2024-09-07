//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Денис Кель on 08.09.2024.
//

import Foundation


protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
