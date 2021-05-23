//
//  SearchingView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/23/21.
//

import SwiftUI

struct SearchingView: View {
    @EnvironmentObject var model: MainViewModel
    @State var searchText = ""

    @Binding var date: Date
    @State var showCopied = false

    @State var searchResult: [OTP] = []

    var body: some View {
        VStack {
            SearchBarView(searchText: $searchText)

            let searchResult = searchText == "" ? self.model.otps : self.model.otps.filter { $0.issuer?.contains(searchText) ?? false || $0.accountname.contains(searchText) }

            List {
                ForEach(searchResult) { otp in
                    OTPRowView(otp: otp, date: self.$date, showCopied: self.$showCopied)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .overlay(
                Group {
                    if searchResult.count == 0 {
                        Text("No Results")
                            .font(.headline)
                    }
                }
            )

            Spacer()
        }

        .overlay(
            CopiedPopupView()
                .opacity(self.showCopied ? 1 : 0)
        )
        .onAppear {
            UITableView.appearance().contentInset.top = -25
        }
        .onDisappear {
            UITableView.appearance().contentInset.top = 0
        }
    }
}
