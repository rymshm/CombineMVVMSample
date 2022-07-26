import UIKit
import Combine

final class ViewModel {
    let changeTextSubject = PassthroughSubject<String?, Never>()
    let changeColorSubject = PassthroughSubject<UIColor?, Never>()

    private let model: ModelProtocol

    private var disposeBag = Set<AnyCancellable>()

    init(model: ModelProtocol = Model()) {
        self.model = model
    }

    func idPasswordChanged(id: String?, password: String?) {
        let result = model.validate(idText: id, passwordText: password)

        switch result {
            case .success:
                changeTextSubject.send("OK!!!")
                changeColorSubject.send(.green)
            case .failure(let error as ModelError):
                changeTextSubject.send(error.errorText)
                changeColorSubject.send(.red)
            case _:
                fatalError("Unexpected pattern.")
        }
    }
}

extension ModelError {
    fileprivate var errorText: String {
        switch self {
            case .invalidIdAndPassword:
                return "IDとPasswordが未入力です。"
            case .invalidId:
                return "IDが未入力です。"
            case .invalidPassword:
                return "Passwordが未入力です。"
        }
    }
}
