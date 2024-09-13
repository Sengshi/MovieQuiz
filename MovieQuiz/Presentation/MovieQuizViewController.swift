import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - AlertPresenter
    private var alertPresenter: AlertPresenter?

    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButtonClicked: UIButton!
    @IBOutlet private weak var yesButtonClicked: UIButton!
    
    // Индекс текущего вопроса и счётчик правильных ответов
    private var currentQuestionIndex = -1
    private var correctAnswers = 0
    
    private let questionsAmount = 10
    private var currentQuestion: QuizQuestion?
    
    private let statisticService: StatisticServiceProtocol
    private let questionFactory: QuestionFactoryProtocol

    required init?(coder: NSCoder) {
        // Инициализация зависимостей
        self.statisticService = StatisticService()
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: nil) // Делегат добавим позже
        super.init(coder: coder)
        // Инициализируем alertPresenter
        self.alertPresenter = AlertPresenter(viewController: self)
        self.questionFactory.setup(delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    private func setupUI() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 20
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
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    // MARK: - Button Actions
    
    @IBAction private func yesButtonTapped(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonTapped(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
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
    
    // Переход к следующему вопросу или результатам
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let text = correctAnswers == questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" : "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
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
    
    // Перезапуск квиза
    private func restartQuiz() {
        currentQuestionIndex = -1
        correctAnswers = 0
        showNextQuestionOrResults()
    }
    
    // MARK: - Loading Indicator
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: "Невозможно загрузить данные")
    }
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.isHidden = false
            self?.activityIndicator.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.isHidden = true
            self?.activityIndicator.startAnimating()
        }
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
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
