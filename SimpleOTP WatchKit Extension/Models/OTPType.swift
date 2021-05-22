//
//  OTPType.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/21/21.
//

enum OTPType: Int, Codable {
    case hotp
    case totp
    case unknown
}
