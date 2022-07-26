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

    func test_changeValidationTextAndColor() {
        XCTContext.runActivity(named: "バリデーションに成功する場合") { _ in
            // Given
            setup()
            fakeModel.result = .success(())

            // When
            viewModel.idPasswordChanged(id: "id", password: "password")

            // Then
            XCTAssertEqual("OK!!!", changedText)
            XCTAssertEqual(UIColor.green, changedColor)

            clean()
        }

        XCTContext.runActivity(named: "バリデーションに失敗する場合") { _ in
            XCTContext.runActivity(named: "idもpasswordも入力されていない場合") { _ in
                setup()
                fakeModel.result = .failure(ModelError.invalidIdAndPassword)

                viewModel.idPasswordChanged(id: nil, password: nil)

                XCTAssertEqual("IDとPasswordが未入力です。", changedText)
                XCTAssertEqual(UIColor.red, changedColor)

                clean()
            }

            XCTContext.runActivity(named: "idが入力されておらず、passwordが入力されている場合") { _ in
                setup()
                fakeModel.result = .failure(ModelError.invalidId)

                viewModel.idPasswordChanged(id: nil, password: "password")

                XCTAssertEqual("IDが未入力です。", changedText)
                XCTAssertEqual(UIColor.red, changedColor)

                clean()
            }

            XCTContext.runActivity(named: "idが入力されていて、passwordが入力されていない場合") { _ in
                setup()
                fakeModel.result = .failure(ModelError.invalidPassword)

                viewModel.idPasswordChanged(id: "id", password: nil)

                XCTAssertEqual("Passwordが未入力です。", changedText)
                XCTAssertEqual(UIColor.red, changedColor)

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
