import UIKit
import XCTest
import Combine
@testable import CombineMVVMSample

class FakeModel: ModelProtocol {
    var result: Result<Void>?

    func validate(idText: String?, passwordText: String?) -> Result<Void> {
        guard let result = result else {
            fatalError("validationResult has not been set.")
        }

        return result
    }
}

class ViewModelTests: XCTestCase {
    private var changedText: String?
    private var changedColor: UIColor?

    private var fakeModel: FakeModel!
    private var viewModel: ViewModel!

    private var disposeBag: Set<AnyCancellable>?

    // UITextFieldのPublisherを表現
    let idTextChangePublisher: PassthroughSubject<String?, Never> = .init()
    let passwordTextChangePublisher: PassthroughSubject<String?, Never> = .init()

    func test_changeValidationTextAndColor() {

        XCTContext.runActivity(named: "バリデーションに成功する場合") { _ in
            // Given
            setup()
            fakeModel.result = .success(())

            // When
            // ユーザ入力をシミュレートするために1文字ずつSubjectに送信してます
            "id".map { String($0) }.forEach {
                idTextChangePublisher.send($0)
            }
            "password".map { String($0) } .forEach {
                passwordTextChangePublisher.send($0)
            }
            // Then
            XCTAssertEqual("OK!!!", changedText)
            XCTAssertEqual(UIColor.green, changedColor)

            clean()
        }

        XCTContext.runActivity(named: "バリデーションに失敗する場合") { _ in
            XCTContext.runActivity(named: "idもpasswordも入力されていない場合") { _ in
                setup()
                fakeModel.result = .failure(ModelError.invalidIdAndPassword)

                // 空文字入力をシミュレート
                "  ".map { String($0) }.forEach {
                    idTextChangePublisher.send($0)
                }
                "  ".map { String($0) } .forEach {
                    passwordTextChangePublisher.send($0)
                }
                XCTAssertEqual("IDとPasswordが未入力です。", changedText)
                XCTAssertEqual(UIColor.red, changedColor)

                clean()
            }

            XCTContext.runActivity(named: "idが入力されておらず、passwordが入力されている場合") { _ in
                setup()
                fakeModel.result = .failure(ModelError.invalidId)

                "  ".map { String($0) }.forEach {
                    idTextChangePublisher.send($0)
                }
                "password".map { String($0) } .forEach {
                    passwordTextChangePublisher.send($0)
                }

                XCTAssertEqual("IDが未入力です。", changedText)
                XCTAssertEqual(UIColor.red, changedColor)

                clean()
            }

            XCTContext.runActivity(named: "idが入力されていて、passwordが入力されていない場合") { _ in
                setup()
                fakeModel.result = .failure(ModelError.invalidPassword)

                let expectation = expectation(description: "async validation")
                var cancellable: AnyCancellable?
                cancellable = viewModel
                    .changeTextSubject
                    .sink {
                        XCTAssertEqual("Passwordが未入力です。", $0)
                        expectation.fulfill()
                        cancellable?.cancel()
                    }
                "id".map { String($0) }.forEach {
                    idTextChangePublisher.send($0)
                }
                "  ".map { String($0) } .forEach {
                    passwordTextChangePublisher.send($0)
                }
                wait(for: [expectation], timeout: 1.0)
                clean()
            }

            /*
            XCTContext.runActivity(named: "非同期でAPIに通信した結果をテストするような場合") { _ in
                setup()
                var cancellable: AnyCancellable?
                fakeModel.result = .failure(ModelError.alreadyExistUserId)

                let validateExpectation = expectation(description: "async validation")
                cancellable = viewModel
                    .changeTextSubject
                    .sink {
                        self.changedText = $0
                        cancellable?.cancel()
                        validateExpectation.fulfill()
                    }
                viewModel.idPasswordChanged(id: "id", password: "password")
                wait(for: [validateExpectation], timeout: 1.0)
                XCTAssertEqual("既に使用されているIDです", changedText)
                clean()
            }
             */
        }
    }

    private func setup() {
        fakeModel = FakeModel()
        viewModel = ViewModel(
            idTextPublisher: idTextChangePublisher.eraseToAnyPublisher(),
            passwordTextPublisher: passwordTextChangePublisher.eraseToAnyPublisher(),
            model: fakeModel
        )
        disposeBag = [
            viewModel
                .changeColorSubject
                .assign(to: \.changedColor, on: self) ,
            viewModel
                .changeTextSubject
                .assign(to: \.changedText, on: self),
        ]
    }

    private func clean() {
        fakeModel = nil
        viewModel = nil
        disposeBag = nil
    }
}
