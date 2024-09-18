//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Денис Кель on 17.09.2024.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func setButtonsEnabled(_ isEnabled: Bool)
    func showNetworkError(message: String)
}

final class MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: "Невозможно загрузить данные")
    }

    weak var viewController: MovieQuizViewControllerProtocol?
    var alertPresenter: AlertPresenter?
    var currentQuestionIndex = 0
    let questionsAmount = 10
    var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticServiceProtocol

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController

        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        self.alertPresenter = AlertPresenter(viewController: viewController as! UIViewController)
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func yesButtonTapped() {
        didButtonTap(isYes: true)
    }
    
    func noButtonTapped() {
        didButtonTap(isYes: false)
    }

    private func didButtonTap(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
         guard let question = question else {
             DispatchQueue.main.async { [weak self] in
                 self?.showNetworkError(message: "Не удалось получить следующий вопрос.")
             }
             return
         }
         
         if question.image.isEmpty {
             DispatchQueue.main.async { [weak self] in
                 self?.showNetworkError(message: "Не удалось получить изображение для вопроса.")
             }
             return
         }
         
         currentQuestion = question
         let viewModel = convert(model: question)
         
         DispatchQueue.main.async { [weak self] in
             self?.viewController?.show(quiz: viewModel)
         }
     }
     
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let text = correctAnswers == questionsAmount
                ? "Поздравляем, вы ответили на 10 из 10!"
                : "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            
            show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
        guard viewController != nil else { return }
        
        let bestGameText = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let gamesCountText = "Всего игр сыграно: \(statisticService.gamesCount)"
        
        let message = "\(result.text)\n\(accuracyText)\n\(gamesCountText)\n\(bestGameText)"
        
        let model = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText
        ) { [weak self] in
            self?.restartQuiz()
        }
        
        alertPresenter?.showAlert(with: model)
    }
    
     func restartQuiz() {
         resetQuestionIndex()
         correctAnswers = 0
         currentQuestion = nil
         questionFactory?.requestNextQuestion()
     }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.setButtonsEnabled(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.setButtonsEnabled(true)
            self.showNextQuestionOrResults()
        }
    }
    
    func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Что-то пошло не так",
            message: message,
            buttonText: "Попробовать ещё раз"
        ) { [weak self] in
            self?.restartQuiz()
        }
        
        alertPresenter?.showAlert(with: model)
    }

 }
