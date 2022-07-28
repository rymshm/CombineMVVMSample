//
//  SwiftUIView.swift
//  CombineMVVMSample
//
//  Created by mashima.ryo on 2022/07/28.
//

import SwiftUI

struct SwiftUIView: View {
    @StateObject private var viewModel: ViewModelForSwiftUI = .init()
    var body: some View {
        VStack {
            Group {
                TextField("ID", text: $viewModel.idText)
                SecureField("password", text: $viewModel.passwordText)
            }
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())

            Text(viewModel.validationResultText)
                .foregroundColor(viewModel.validationResultTextColor)
                .padding(.top, 48)
            Spacer()
        }
        .padding()
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
