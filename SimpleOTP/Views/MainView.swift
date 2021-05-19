//
//  MainView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var model: MainViewModel

    @State var showAddOTP = false
    @State var isQRScan = false
    @State var showAddSheet = false

    @State var showDeleteConfirmation = false
    @State var deleteRow: IndexSet?

    @State var showCopied = false

    @State var date = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: AddOTPView(addViaScan: isQRScan), isActive: $showAddOTP) { EmptyView() }
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
                                self.isQRScan = true
                                self.showAddOTP = true
                            }, .default(Text("Add Manually")) {
                                self.isQRScan = false
                                self.showAddOTP = true
                            }, .cancel()])
                        }
                    }
                } else {
                    List {
                        ForEach(self.model.otps) { otp in
                            OTPRowView(otp: otp, date: self.$date, showCopied: self.$showCopied)
                        }
                        .onDelete(perform: self.deleteOTPRow)
                    }
                    .onReceive(timer) { result in
                        withAnimation {
                            date = result
                        }
                    }
                    .alert(isPresented: $showDeleteConfirmation) {
                        Alert(title: Text("Are you sure you want to delete this OTP"), message: Text("This OTP will be deleted immediately. You can't undo this action."), primaryButton: .destructive(Text("Delete")) {
                            withAnimation {
                                if self.deleteRow != nil {
                                    self.model.otps.remove(atOffsets: self.deleteRow!)
                                    self.model.saveAllOTPs()
                                }
                            }
                        }, secondaryButton: .default(Text("Cancel")) {
                            self.deleteRow = nil
                        })
                    }
                }
            }
            .overlay(
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
                .padding(.bottom, 150)
                .opacity(self.showCopied ? 1 : 0)
            )
            .navigationTitle("Simple OTP")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if model.otps.count > 0 {
                        Menu {
                            Button(action: {
                                self.isQRScan = true
                                self.showAddOTP = true
                            }) {
                                Text("Scan QR Code")
                            }

                            Button(action: {
                                self.isQRScan = false
                                self.showAddOTP = true
                            }) {
                                Text("Add Manually")
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(.title))
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

    private func deleteOTPRow(indexSet: IndexSet) {
        self.deleteRow = indexSet
        self.showDeleteConfirmation = true
    }
}
