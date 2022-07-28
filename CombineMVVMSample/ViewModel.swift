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
            .map { model.validate(idText: $0, passwordText: $1) }
            .eraseToAnyPublisher()
        event.sink { result in
            switch result {
                case .success:
                    self.changeTextSubject.send("OK!!!")
                    self.changeColorSubject.send(.green)
                case .failure(let error):
                    self.changeTextSubject.send(error.errorText)
                    self.changeColorSubject.send(.red)
            }
        }
        .store(in: &disposeBag)
    }
}

extension ModelError {
    var errorText: String {
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
