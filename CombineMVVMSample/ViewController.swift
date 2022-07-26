import UIKit
import Combine

final class ViewController: UIViewController {
    @IBOutlet private weak var idTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var validationLabel: UILabel!

    private lazy var viewModel = ViewModel()
    private lazy var disposeBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        idTextField.addTarget(
            self,
            action: #selector(textFieldEditingChanged),
            for: .editingChanged)
        passwordTextField.addTarget(
            self,
            action: #selector(textFieldEditingChanged),
            for: .editingChanged)

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

extension ViewController {
    @objc func textFieldEditingChanged(sender: UITextField) {
        viewModel.idPasswordChanged(
            id: idTextField.text,
            password: passwordTextField.text)
    }
}
