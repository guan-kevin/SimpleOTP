//
//  OTP.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import Foundation

enum Encryption: Int, Codable {
    case sha1
    case sha256
    case sha512
}

struct OTP: Codable, Hashable, Identifiable {
    var id = UUID()
    let type: OTPType
    let issuer: String?
    let accountname: String
    let secret: String
    let digits: Int
    let encryptions: Encryption
    let counter_period: Int
}
