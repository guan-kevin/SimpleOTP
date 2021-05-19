//
//  LockView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftUI

struct LockView: View {
    @EnvironmentObject var model: MainViewModel

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock")
                .foregroundColor(.blue)
                .font(.system(size: 40))
            Text("App Locked!")
                .font(.headline)
        }
        .padding(.bottom, 50)
    }
}
