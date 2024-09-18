import UIKit


final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    func show(quiz result: QuizResultsViewModel) {
        presenter?.show(quiz: result)
    }
    
    func showNetworkError(message: String) {
        presenter?.showNetworkError(message: message)
    }
    
    // MARK: - Lifecycle
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noButtonClicked: UIButton!
    @IBOutlet weak var yesButtonClicked: UIButton!
        
    private var presenter: MovieQuizPresenter?

    required init?(coder: NSCoder) {
        
        // Инициализация зависимостей
        super.init(coder: coder)
        self.presenter = MovieQuizPresenter(
            viewController: self
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActivityIndicator()
        showLoadingIndicator()
        presenter?.questionFactory?.loadData()
    }
    
    private func setupUI() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    // MARK: - Button Actions
    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        presenter?.yesButtonTapped()
    }
    
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        presenter?.noButtonTapped()
    }

    // MARK: - Loading Indicator
    
    func showLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButtonClicked.isEnabled = false
        noButtonClicked.isEnabled = false

    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter?.didReceiveNextQuestion(question: question)
    }
    
    func setButtonsEnabled(_ isEnabled: Bool) {
        yesButtonClicked.isEnabled = isEnabled
        noButtonClicked.isEnabled = isEnabled
    }

}
