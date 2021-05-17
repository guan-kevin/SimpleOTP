//
//  ScanQRView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import AVFoundation
import CodeScanner
import Combine
import SwiftUI

struct ScanQRView: View {
    @EnvironmentObject var model: MainViewModel
    @Environment(\.presentationMode) var presentation
    
    @State var loaded = false
    @State var showScanner = false
    @State var hasPermission = false
    
    @State var type = 0
    @State var accountname = ""
    @State var issuer = ""
    @State var secret = ""
    @State var algorithm = 0
    @State var digits = ""
    @State var counter = ""
    @State var period = ""
    
    var body: some View {
        Group {
            Group {
                if hasPermission {
                    Form {
                        Button(action: {
                            self.showScanner = true
                        }) {
                            Label(
                                title: { Text("Scan QR Code") },
                                icon: { Image(systemName: "qrcode") }
                            )
                        }
                        
                        Section {
                            TextField("Account", text: $accountname)
                            TextField("Issuer (Optional)", text: $issuer)
                            
                            HStack {
                                Text("OTP Type")
                                
                                Picker(selection: $type, label: Text("")) {
                                    Text("TOTP").tag(0)
                                    Text("HOTP").tag(1)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            HStack {
                                Text("Algorithm")
                                
                                Picker(selection: $algorithm, label: Text("")) {
                                    Text("SHA1").tag(0)
                                    Text("SHA256").tag(1)
                                    Text("SHA512").tag(2)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            TextField("Secret", text: $secret)
                            
                            HStack {
                                Text("Digits")
                                
                                TextField("6", text: $digits)
                                    .keyboardType(.numberPad)
                                    .onReceive(Just(digits)) { newValue in
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                        if filtered != newValue {
                                            self.digits = filtered
                                        }
                                    }
                            }
                            
                            if type == 0 {
                                HStack {
                                    Text("Period")
                                    
                                    TextField("30", text: $period)
                                        .keyboardType(.numberPad)
                                        .onReceive(Just(digits)) { newValue in
                                            let filtered = newValue.filter { "0123456789".contains($0) }
                                            if filtered != newValue {
                                                self.period = filtered
                                            }
                                        }
                                }
                            } else {
                                HStack {
                                    Text("Counter")
                                    
                                    TextField("0", text: $counter)
                                        .keyboardType(.numberPad)
                                        .onReceive(Just(digits)) { newValue in
                                            let filtered = newValue.filter { "0123456789".contains($0) }
                                            if filtered != newValue {
                                                self.counter = filtered
                                            }
                                        }
                                }
                            }
                        }
                        
                        Button(action: {
                            if secret == "" || accountname == "" {
                                print("NO INFO")
                                return
                            }
                            
                            var otp_type: OTPType
                            switch type {
                            case 0:
                                otp_type = .totp
                            case 1:
                                otp_type = .hotp
                            default:
                                print("Incorrect OTP Type")
                                return
                            }
                            
                            var otp_digits: Int
                            
                            if digits == "" {
                                otp_digits = 6
                            } else {
                                if let digits = Int(digits) {
                                    otp_digits = digits
                                } else {
                                    print("Incorrect Digits")
                                    return
                                }
                            }
                            
                            var encryptions: Encryption
                            switch algorithm {
                            case 0:
                                encryptions = .sha1
                            case 1:
                                encryptions = .sha256
                            case 2:
                                encryptions = .sha512
                            default:
                                print("Incorrect Encryption")
                                return
                            }
                            
                            var otp_counter = 0
                            var otp_period = 30
                            
                            if counter != "" {
                                if let counter = Int(counter) {
                                    otp_counter = counter
                                } else if otp_type == .hotp {
                                    print("Incorrect Counter")
                                    return
                                }
                            }
                            
                            if period != "" {
                                if let period = Int(period) {
                                    otp_period = period
                                } else if otp_type == .totp {
                                    print("Incorrect Period")
                                    return
                                }
                            }
                            
                            let result = OTP(type: otp_type, issuer: issuer, accountname: accountname, secret: secret, digits: otp_digits, encryptions: encryptions, counter_period: otp_type == .hotp ? otp_counter : otp_period)
                                                
                            self.model.addOTP(otp: result)
                            
                            self.presentation.wrappedValue.dismiss()
                        }) {
                            Text("Add")
                        }
                    }
                } else {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.yellow)
                            .font(.system(size: 80))
                        Text("SimpleOTP doesn't have permission to use your camera!")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .navigationBarTitle("ADD OTP", displayMode: .inline)
        }
        .sheet(isPresented: $showScanner) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "debug", completion: self.handleScan)
        }
        .onAppear {
            guard loaded == false else { return }
            
            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                self.hasPermission = true
                self.showScanner = true
            } else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        self.hasPermission = true
                        self.showScanner = true
                    }
                })
            }
            
            self.loaded = true
        }
    }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        showScanner = false

        switch result {
        case .success(let code):
            if let url = URL(string: code) {
                if url.isValidScheme() {
                    let labels = url.getOTPLabel()
                    let type: OTPType = url.getOTPType()

                    switch type {
                    case .totp:
                        self.type = 0
                    case .hotp:
                        self.type = 1
                    default:
                        break
                    }
                    
                    if labels.count == 0 {
                        print("No Label")
                        return
                    } else if labels.count == 1 {
                        accountname = labels.first!
                    } else {
                        issuer = labels[0]
                        accountname = labels[1]
                    }
                    
                    secret = url.getQuery("secret") ?? ""
                    
                    if issuer == "" {
                        issuer = url.getQuery("issuer") ?? ""
                    }
                    
                    switch url.getQuery("algorithm")?.lowercased() {
                    case "sha1":
                        algorithm = 0
                    case "sha256":
                        algorithm = 1
                    case "sha512":
                        algorithm = 2
                    default:
                        break
                    }
                    
                    digits = url.getQuery("digits") ?? "6"
                    
                    if let url_counter = url.getQuery("counter") {
                        counter = url_counter
                    }
                    
                    if let url_period = url.getQuery("period") {
                        period = url_period
                    }
                }
            }
        case .failure:
            print("Scanning failed")
        }
    }
}
