//
//  ContentView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var model: MainViewModel
    
    var body: some View {
        if model.isLocked {
            LockView()
        } else {
            MainView()
        }
    }
}
