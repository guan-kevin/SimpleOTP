//
//  OTPType.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

enum OTPType: Int, Codable {
    case hotp
    case totp
    case unknown
}
