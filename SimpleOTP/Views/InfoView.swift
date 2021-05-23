//
//  InfoView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/22/21.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        Form {
            Section(header: Text("SwiftOTP")) {
                Text("https://github.com/lachlanbell/SwiftOTP/blob/master/LICENSE")
            }

            Section(header: Text("Valet")) {
                Text("https://github.com/square/Valet/blob/master/LICENSE")
            }
        }
        .navigationBarTitle("Acknowledgements", displayMode: .inline)
    }
}
