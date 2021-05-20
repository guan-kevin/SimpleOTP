//
//  CopiedPopupView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/19/21.
//

import SwiftUI

struct CopiedPopupView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 150, height: 150)
                .foregroundColor(.gray)
                .cornerRadius(20)
                .opacity(0.8)
            VStack {
                Image(systemName: "checkmark")
                    .font(.largeTitle)
                Text("Copied")
            }
            .zIndex(1)
        }
    }
}
