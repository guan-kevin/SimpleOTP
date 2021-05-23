//
//  SearchBarView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/23/21.
//

import SwiftUI

struct SearchBarView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    @Binding var searchText: String

    var body: some View {
        HStack {
            Group {
                SearchBarTextField(text: $searchText)
                    .frame(height: 25)
                    .padding(.all, 10)
                    .padding(.horizontal, 25)
                    .background(colorScheme == .light ? Color(.systemGray6) : Color.black)
                    .cornerRadius(8)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)

                            Button(action: {
                                self.searchText = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    )
            }
            .padding([.leading, .top], 15)

            Button(action: {
                self.presentation.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }
            .padding(.trailing, 15)
            .padding(.top, 15)
        }
    }
}

struct SearchBarTextField: UIViewRepresentable {
    @Binding var text: String
    var isFirstResponder = true

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBarTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.placeholder = "Search..."
        return textField
    }

    func makeCoordinator() -> SearchBarTextField.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<SearchBarTextField>) {
        uiView.text = text
        if isFirstResponder, !context.coordinator.didBecomeFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
