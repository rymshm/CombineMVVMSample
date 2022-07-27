import UIKit
import Combine

final class ViewController: UIViewController {
    @IBOutlet private weak var idTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var validationLabel: UILabel!

    private lazy var viewModel = ViewModel(idTextPublisher: idTextField.textDidChangePublisher,
                                           passwordTextPublisher: passwordTextField.textDidChangePublisher)
    private lazy var disposeBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel
            .changeColorSubject
            .assign(to: \.textColor, on: validationLabel)
            .store(in: &disposeBag)
        viewModel
            .changeTextSubject
            .assign(to: \.text, on: validationLabel)
            .store(in: &disposeBag)
    }
}

extension UITextField {
    var textDidChangePublisher: AnyPublisher<String?, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }
}
