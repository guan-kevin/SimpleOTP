//
//  MainViewModel.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/20/21.
//

import WatchKit

final class MainViewModel: ObservableObject {
    var provider: WatchConnectivityProvoder!

    init() {
        print("INIT")
        provider = WatchConnectivityProvoder()
        provider.startSession()
    }
}
