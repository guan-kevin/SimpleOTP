//
//  OTPGenerator.swift
//  SimpleOTP Mac App
//
//  Created by Kevin Guan on 5/24/21.
//

import Foundation
import SwiftOTP

class OTPGenerator {
    static func getOTPCode(otp: OTP, date: Date = Date()) -> String? {
        guard let data = base32DecodeToData(otp.secret) else { return nil }

        var alg: OTPAlgorithm
        switch otp.encryptions {
        case .sha1:
            alg = .sha1
        case .sha256:
            alg = .sha256
        case .sha512:
            alg = .sha512
        }

        if otp.type == .totp {
            let totp = TOTP(secret: data, digits: otp.digits, timeInterval: otp.period, algorithm: alg)
            return totp?.generate(time: date)
        } else if otp.type == .hotp {
            let hotp = HOTP(secret: data, digits: otp.digits, algorithm: alg)
            return hotp?.generate(counter: otp.counter)
        } else {
            return nil
        }
    }
}
