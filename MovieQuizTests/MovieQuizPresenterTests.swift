//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Денис Кель on 18.09.2024.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var didShowLoadingIndicator = false
    var didHideLoadingIndicator = false
    var didHighlightImageBorder = false
    var didShowQuizStep = true
    var didShowQuizResult = false
    var didShowNetworkError = false
    var yesButtonClicked = false
    var noButtonClicked = false

    func show(quiz step: QuizStepViewModel) {
        didShowQuizStep = true
    }
    
    func show(quiz result: QuizResultsViewModel) {
        didShowQuizResult = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        didHighlightImageBorder = true
    }
    
    func showLoadingIndicator() {
        didShowLoadingIndicator = true
    }
    
    func hideLoadingIndicator() {
        didHideLoadingIndicator = true
    }
    
    func showNetworkError(message: String) {
        didShowNetworkError = true
    }
    
    func setButtonsEnabled(_ isEnabled: Bool) {
        yesButtonClicked = true
        noButtonClicked = true
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        let imageData = Data()
        let question = QuizQuestion(image: imageData, text: "Question Text", correctAnswer: true)
        sut.didReceiveNextQuestion(question: question)
        XCTAssertTrue(viewControllerMock.didShowQuizStep)
        let viewModel = sut.convert(model: question)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertNotNil(viewModel.image)
    }
}
