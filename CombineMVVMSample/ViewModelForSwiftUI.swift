//
//  ViewModelForSwiftUI.swift
//  CombineMVVMSample
//
//  Created by mashima.ryo on 2022/07/28.
//

import Foundation
import Combine
import SwiftUI

final class ViewModelForSwiftUI: ObservableObject {
    // Input
    @Published var idText: String = ""
    @Published var passwordText: String = ""
    // Output
    @Published private(set) var validationResultText: String = "IDとパスワードを入力してください"
    @Published private(set) var validationResultTextColor: Color = .black

    private let model: ModelProtocol
    private var disposeBag = Set<AnyCancellable>()

    init(model: ModelProtocol = Model()) {
        self.model = model
        let event = Publishers
            .CombineLatest($idText, $passwordText)
            .dropFirst()
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { model.validate(idText: $0, passwordText: $1) }
            .eraseToAnyPublisher()
        event.sink { result in
            switch result {
                case .success:
                    self.validationResultText = "OK!!!"
                    self.validationResultTextColor = .green
                case .failure(let error):
                    self.validationResultText = error.errorText
                    self.validationResultTextColor = .red
            }
        }
        .store(in: &disposeBag)
    }

}
