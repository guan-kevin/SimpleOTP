//
//  OTPGenerator.swift
//  SimpleOTP Mac App
//
//  Created by Kevin Guan on 5/24/21.
//

import Foundation
import SwiftOTP

class OTPGenerator {
    static func getOTPAlgorithm(otp: OTP) -> OTPAlgorithm {
        var alg: OTPAlgorithm
        switch otp.encryptions {
        case .sha1:
            alg = .sha1
        case .sha256:
            alg = .sha256
        case .sha512:
            alg = .sha512
        }

        return alg
    }

    static func getOTPCode(otp: OTP, date: Date = Date()) -> String? {
        guard let data = base32DecodeToData(otp.secret) else { return nil }

        let alg = getOTPAlgorithm(otp: otp)

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

    static func getTOTP(otp: OTP) -> TOTP? {
        guard let data = base32DecodeToData(otp.secret) else { return nil }

        let alg = getOTPAlgorithm(otp: otp)

        if otp.type == .totp {
            return TOTP(secret: data, digits: otp.digits, timeInterval: otp.period, algorithm: alg)
        }

        return nil
    }

    static func getHOTP(otp: OTP) -> HOTP? {
        guard let data = base32DecodeToData(otp.secret) else { return nil }

        let alg = getOTPAlgorithm(otp: otp)

        if otp.type == .hotp {
            return HOTP(secret: data, digits: otp.digits, algorithm: alg)
        }

        return nil
    }
}
