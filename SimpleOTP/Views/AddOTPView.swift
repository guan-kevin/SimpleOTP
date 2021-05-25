//
//  AddOTPView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/18/21.
//

import AVFoundation
import CodeScanner
import Combine
import SwiftUI

struct AddOTPView: View {
    @EnvironmentObject var model: MainViewModel
    @Environment(\.presentationMode) var presentation
    @ObservedObject var addOTPModel = AddOTPViewModel()
    
    let addViaScan: Bool
    
    @State var loaded = false
    @State var hasPermission = false
    
    var body: some View {
        Group {
            Group {
                Form {
                    if addViaScan {
                        if hasPermission {
                            Button(action: {
                                self.addOTPModel.showScanner = true
                            }) {
                                Label(
                                    title: { Text("Scan QR Code") },
                                    icon: { Image(systemName: "qrcode") }
                                )
                            }
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(.title))
                                    .foregroundColor(.yellow)
                                
                                Text("SimpleOTP doesn't have permission to use your camera!")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                      
                    Section(header: Text("")) {
                        TextField("Account", text: $addOTPModel.accountname)
                        TextField("Issuer (Optional)", text: $addOTPModel.issuer)
                            
                        HStack {
                            Text("OTP Type")
                                
                            Picker(selection: $addOTPModel.type, label: Text("")) {
                                Text("TOTP").tag(0)
                                Text("HOTP").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                            
                        HStack {
                            Text("Algorithm")
                                
                            Picker(selection: $addOTPModel.algorithm, label: Text("")) {
                                Text("SHA1").tag(0)
                                Text("SHA256").tag(1)
                                Text("SHA512").tag(2)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                            
                        TextField("Secret", text: $addOTPModel.secret)
                            
                        HStack {
                            Text("Digits")
                                
                            TextField("6", text: $addOTPModel.digits)
                                .keyboardType(.numberPad)
                        }
                            
                        if self.addOTPModel.type == 0 {
                            HStack {
                                Text("Period")
                                    
                                TextField("30", text: $addOTPModel.period)
                                    .keyboardType(.numberPad)
                            }
                        } else {
                            HStack {
                                Text("Counter")
                                    
                                TextField("0", text: $addOTPModel.counter)
                                    .keyboardType(.numberPad)
                            }
                        }
                    }
                   
                    Button(action: {
                        let result = self.addOTPModel.generateOTP()
                        
                        if result != nil {
                            if !self.model.checkIfExists(otp: result!) {
                                self.model.addOTP(otp: result!)
                                    
                                self.presentation.wrappedValue.dismiss()
                            } else {
                                self.addOTPModel.alertMessage = "Account already exists!"
                                self.addOTPModel.showAlert = true
                            }
                        }
                    }) {
                        Text("Add")
                    }
                }
            }
            .navigationBarTitle("ADD OTP", displayMode: .inline)
        }
        .sheet(isPresented: $addOTPModel.showScanner) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "debug", completion: self.addOTPModel.handleScan)
        }
        .alert(isPresented: $addOTPModel.showAlert) {
            Alert(title: Text(self.addOTPModel.alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            guard !loaded && addViaScan else { return }
            
            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                self.hasPermission = true
                self.addOTPModel.showScanner = true
            } else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        self.hasPermission = true
                        self.addOTPModel.showScanner = true
                    }
                })
            }
            
            self.loaded = true
        }
    }
}
