import UIKit
import Combine

final class ViewModel {
    let changeTextSubject = PassthroughSubject<String?, Never>()
    let changeColorSubject = PassthroughSubject<UIColor?, Never>()

    private let model: ModelProtocol

    private var disposeBag = Set<AnyCancellable>()

    init(idTextPublisher: AnyPublisher<String?, Never>,
         passwordTextPublisher: AnyPublisher<String?, Never>,
         model: ModelProtocol = Model()) {
        self.model = model
        let event = Publishers
            .CombineLatest(idTextPublisher, passwordTextPublisher)
            .dropFirst()
//            .debounce(for: 0.1, scheduler: RunLoop.main)
            .map { (idText, passwordText) -> Result<Void> in
                model.validate(idText: idText, passwordText: passwordText)
            }
            .eraseToAnyPublisher()
        event.sink { result in
            switch result {
                case .success:
                    self.changeTextSubject.send("OK!!!")
                    self.changeColorSubject.send(.green)
                case .failure(let error as ModelError):
                    self.changeTextSubject.send(error.errorText)
                    self.changeColorSubject.send(.red)
                case _:
                    fatalError("Unexpected pattern.")
            }
        }
        .store(in: &disposeBag)
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
