//
//  SimpleOTPApp.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftUI

@main
struct SimpleOTPApp: App {
    @ObservedObject var model = MainViewModel()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .onChange(of: scenePhase, perform: { value in
                    switch value {
                    case .active:
                        if model.isAppLocked() {
                            model.unlockApp()
                        }
                        
                        self.model.list()
                    case .background:
                        model.isLocked = true
                    case .inactive:
                        break
                    @unknown default:
                        break
                    }
                })
                .onAppear {
                    model.unlockApp()
                }
                .onOpenURL { url in
                    handleQRData(url: url)
                }
        }
    }
    
    func handleQRData(url: URL) {
        if url.isValidScheme() {
            // OTP Type
            let type: OTPType = url.getOTPType()
        
            // Account name and Issuer
            let labels = url.getOTPLabel()
            var accountname = ""
            var issuer = ""
            
            if labels.count == 0 {
                return
            } else if labels.count == 1 {
                accountname = labels.first!
            } else {
                issuer = labels[0]
                accountname = labels[1]
            }
            
            if issuer == "" {
                issuer = url.getQuery("issuer") ?? ""
            }
            
            // Secret
            let secret = url.getQuery("secret")?.replacingOccurrences(of: " ", with: "") ?? ""
            
            if secret == "" {
                return
            }

            // Algorithm
            var algorithm: Encryption
            switch url.getQuery("algorithm")?.lowercased() {
            case "sha1":
                algorithm = .sha1
            case "sha256":
                algorithm = .sha256
            case "sha512":
                algorithm = .sha512
            default:
                algorithm = .sha1
            }
            
            // Digit
            let digits = url.getQuery("digits") ?? "6"
            var otp_digits: Int
                
            if digits == "" {
                otp_digits = 6
            } else {
                if let digits = Int(digits) {
                    otp_digits = digits
                    
                    if !(6 ... 8 ~= digits) {
                        return
                    }
                } else {
                    return
                }
            }
            
            // Counter
            var counter = ""
            var otp_counter: UInt64 = 0
            
            if let url_counter = url.getQuery("counter") {
                counter = url_counter
            }
                
            if counter != "" {
                if Int64(counter) ?? 0 < 0 {
                    return
                }
                
                if let counter = UInt64(counter) {
                    otp_counter = counter
                } else if type == .hotp {
                    return
                }
            }
                
            // Period
            var period = ""
            var otp_period: Int = 30
            
            if let url_period = url.getQuery("period") {
                period = url_period
            }
            
            if period != "" {
                if let period = Int(period) {
                    otp_period = period
                    
                    if period < 0 {
                        return
                    }
                } else if type == .totp {
                    return
                }
            }
            
            let result = OTP(type: type, issuer: issuer, accountname: accountname, secret: secret, digits: otp_digits, encryptions: algorithm, period: otp_period, counter: otp_counter)
            
            if OTPGenerator.getOTPCode(otp: result) == nil {
                return
            } else {
                self.model.addOTP(otp: result)
            }
        }
    }
}
