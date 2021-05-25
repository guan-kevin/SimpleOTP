//
//  MainView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var model: MainViewModel

    @State var showSettings = false
    @State var showAddOTP = false
    @State var isQRScan = false

    @State var showAddSheet = false

    @State var showDeleteConfirmation = false
    @State var deleteRow: IndexSet?

    @State var showCopied = false

    @State var currentEditMode: EditMode = .inactive

    @State var showSearchSheet = false

    @State var date = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: AddOTPView(addViaScan: isQRScan), isActive: $showAddOTP) { EmptyView() }
                NavigationLink(destination: SettingsView(), isActive: $showSettings) { EmptyView() }
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
                        .onMove(perform: move)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .onReceive(timer) { result in
                        guard !showSettings, !showAddOTP else { return }
                        if Int(result.timeIntervalSince1970) % 15 == 0 {
                            if UserDefaults.standard.bool(forKey: "useiCloud") {
                                self.model.list()
                            }
                        }
                        withAnimation {
                            date = result
                        }
                    }
                    .onAppear {
                        date = Date()
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
                CopiedPopupView()
                    .padding(.bottom, 150)
                    .opacity(self.showCopied ? 1 : 0)
            )
            .navigationTitle("Simple OTP")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if self.currentEditMode == .active {
                        Button(action: {
                            self.currentEditMode = .inactive
                            self.model.saveAllOTPs()
                        }) {
                            Text("Done")
                        }
                    } else if model.otps.count > 0 {
                        Button(action: {
                            self.showSearchSheet = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(.title2))
                        }

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
                                .font(.system(.title2))
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    if self.currentEditMode != .active {
                        Menu {
                            Button(action: {
                                self.showSettings = true
                            }) {
                                Text("Settings")
                            }

                            Button(action: {
                                self.currentEditMode = .active
                            }) {
                                Text("Edit")
                            }
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(.title2))
                        }
                    }
                }
            }
            .environment(\.editMode, self.$currentEditMode)
        }
        .sheet(isPresented: $showSearchSheet) {
            SearchingView(date: self.$date)
                .environmentObject(self.model)
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        self.model.otps.move(fromOffsets: source, toOffset: destination)
    }

    private func deleteOTPRow(indexSet: IndexSet) {
        self.deleteRow = indexSet
        self.showDeleteConfirmation = true
    }
}
