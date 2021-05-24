//
//  OTPType.swift
//  SimpleOTP Mac App
//
//  Created by Kevin Guan on 5/23/21.
//

enum OTPType: Int, Codable {
    case hotp
    case totp
    case unknown
}
