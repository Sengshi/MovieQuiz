import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - AlertPresenter
    private var alertPresenter: AlertPresenter?

    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private weak var noButtonClicked: UIButton!
    @IBOutlet private weak var yesButtonClicked: UIButton!
    // переменная с индексом текущего вопроса, начальное значение 0, но так как у нас запуск происходит из метода showNextQuestionOrResults, и мы первым делом прибавляем 1, то запускаемся с -1
    private var currentQuestionIndex = -1
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol
    private let questionFactory: QuestionFactoryProtocol

    required init?(coder: NSCoder) {
        // Инициализация зависимостей для работы со сторибордом или XIB
        self.statisticService = StatisticService()
        self.questionFactory = QuestionFactory()
        super.init(coder: coder)
        // Инициализируем alertPresenter после super.init
        self.alertPresenter = AlertPresenter(viewController: self)
        // Устанавливаем делегат для фабрики вопросов
        self.questionFactory.setup(delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = UIColor.clear.cgColor // делаем рамку белой
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        showNextQuestionOrResults()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            print("Ошибка: не удалось получить следующий вопрос.")
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    //Нажатие на "Да"
    @IBAction private func yesButtonTapped(_ sender: Any) {
        //let question = questions[currentQuestionIndex]
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    // Нажатие на "Нет"
    @IBAction private func noButtonTapped(_ sender: Any) {
        //let question = questions[currentQuestionIndex]
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    // Сменить цвет рамки в зависимости от точности ответа
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButtonClicked.isEnabled = false
        noButtonClicked.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.yesButtonClicked.isEnabled = true
            self.noButtonClicked.isEnabled = true
            self.showNextQuestionOrResults()
        }
        
    }
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            // идём в состояние "Результат квиза"
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel) // 3
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion() // Запрос нового вопроса
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let bestGameText = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let accuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let gamesCountText = "Всего игр сыграно: \(statisticService.gamesCount)"
        
        let message = "\(result.text)\n\(accuracyText)\n\(gamesCountText)\n\(bestGameText)"
        
        let model = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.restartQuiz()
            }
        )
        
        alertPresenter?.showAlert(with: model)
    }
    
    // Перезапустить игру
    private func restartQuiz() {
        currentQuestionIndex = -1
        correctAnswers = 0
        showNextQuestionOrResults()
    }
}
