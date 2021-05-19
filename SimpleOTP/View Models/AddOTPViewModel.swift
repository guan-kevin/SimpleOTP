//
//  AddOTPViewModel.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/18/21.
//

import CodeScanner
import Foundation
import SwiftOTP

final class AddOTPViewModel: ObservableObject {
    @Published var showScanner = false
    @Published var showAlert = false
    var alertMessage = ""
    
    @Published var type = 0
    @Published var accountname = ""
    @Published var issuer = ""
    @Published var secret = ""
    @Published var algorithm = 0
    @Published var digits = ""
    @Published var counter = ""
    @Published var period = ""
    
    func generateOTP() -> OTP? {
        if secret == "" {
            alertMessage = "Please enter the OTP secret!"
            showAlert = true
            return nil
        }
        
        if accountname == "" {
            alertMessage = "Please enter your account name!"
            showAlert = true
            return nil
        }
            
        var otp_type: OTPType
        switch type {
        case 0:
            otp_type = .totp
        case 1:
            otp_type = .hotp
        default:
            assertionFailure("Unknown OTP Type: \(type)")
            return nil
        }
            
        var otp_digits: Int
            
        if digits == "" {
            otp_digits = 6
        } else {
            if let digits = Int(digits) {
                otp_digits = digits
                
                if !(6 ... 8 ~= digits) {
                    alertMessage = "Digit must between 6 and 8"
                    showAlert = true
                    return nil
                }
            } else {
                alertMessage = "Digit must be an integer"
                showAlert = true
                return nil
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
            assertionFailure("Unknown algorithm: \(algorithm)")
            return nil
        }
            
        var otp_counter: UInt64 = 0
        var otp_period: Int = 30
            
        if counter != "" {
            if Int64(counter) ?? 0 < 0 {
                alertMessage = "Counter must be larger than or equal to 0"
                showAlert = true
                return nil
            }
            
            if let counter = UInt64(counter) {
                otp_counter = counter
            } else if otp_type == .hotp {
                alertMessage = "Counter must be an integer"
                showAlert = true
                return nil
            }
        }
            
        if period != "" {
            if let period = Int(period) {
                otp_period = period
                
                if period < 0 {
                    alertMessage = "Period must be larger than or equal to 0"
                    showAlert = true
                    return nil
                }
            } else if otp_type == .totp {
                alertMessage = "Period must be an integer"
                showAlert = true
                return nil
            }
        }
            
        let result = OTP(type: otp_type, issuer: issuer, accountname: accountname, secret: secret, digits: otp_digits, encryptions: encryptions, period: otp_period, counter: otp_counter)
        
        if OTPGenerator.getOTPCode(otp: result) == nil {
            alertMessage = "OTP secret is invalid"
            showAlert = true
            return nil
        }
        
        return result
    }

    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        showScanner = false
        
        resetFields()

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
                        alertMessage = "This OTP Type is invalid"
                        showAlert = true
                        resetFields()
                        return
                    }
                    
                    if labels.count == 0 {
                        alertMessage = "This QR code doesn't contain label"
                        showAlert = true
                        resetFields()
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
                        alertMessage = "This OTP algorithm is invalid"
                        showAlert = true
                        resetFields()
                        return
                    }
                    
                    digits = url.getQuery("digits") ?? "6"
                    
                    if let url_counter = url.getQuery("counter") {
                        counter = url_counter
                    }
                    
                    if let url_period = url.getQuery("period") {
                        period = url_period
                    }
                    
                    return
                }
            }
            
            alertMessage = "This QR code is invalid"
            showAlert = true
            resetFields()
        case .failure:
            alertMessage = "Unable to scan QR code"
            showAlert = true
        }
    }
    
    func resetFields() {
        type = 0
        accountname = ""
        issuer = ""
        secret = ""
        algorithm = 0
        digits = ""
        counter = ""
        period = ""
    }
}
