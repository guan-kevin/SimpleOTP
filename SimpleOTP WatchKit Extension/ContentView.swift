//
//  ContentView.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: MainViewModel

    var body: some View {
        VStack {
            Button(action: {
                print(self.model.provider.session?.isReachable)
            }) {
                Text("TEST")
            }
            
            Button(action: {
                self.model.provider.fetch()
            }) {
                Text("TEST2")
            }
        }
    }
}
