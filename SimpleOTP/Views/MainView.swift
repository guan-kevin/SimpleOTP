//
//  MainView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var model: MainViewModel

    @State var showQRScanner = false
    @State var showAddSheet = false

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: ScanQRView(), isActive: $showQRScanner) { EmptyView() }
                if model.otps.count == 0 {
                    VStack(spacing: 15) {
                        Text("You don't have any account yet")
                            .multilineTextAlignment(.center)
                        Button(action: {
                            self.showAddSheet.toggle()
                        }) {
                            HStack {
                                Text("Add")
                                    .padding(.vertical, 13)
                                    .frame(width: 225)
                            }
                            .contentShape(Rectangle())
                        }
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10.0)
                        .actionSheet(isPresented: $showAddSheet) {
                            ActionSheet(title: Text("Let add your first account!"), buttons: [.default(Text("Scan QR Code")) {
                                self.showQRScanner = true
                            }, .default(Text("Add Manually")) {}, .cancel()])
                        }
                    }
                } else {
                    List {
                        ForEach(self.model.otps) { otp in
                            Text(otp.accountname)
                        }
                    }
                }
            }
            .navigationTitle("Simple OTP")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if model.otps.count > 0 {
                        Menu {
                            Button(action: {
                                self.showQRScanner = true
                            }) {
                                Text("Scan QR Code")
                            }

                            Button(action: {}) {
                                Text("Add Manually")
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 21))
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}
