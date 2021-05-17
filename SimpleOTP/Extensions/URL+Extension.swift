//
//  URL+Extension.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import Foundation


extension URL {
    func isValidScheme() -> Bool {
        return self.scheme == "otpauth"
    }
    
    func getOTPType() -> OTPType {
        switch self.host {
        case "totp":
            return .totp
        case "hotp":
            return .hotp
        default:
            return .unknown
        }
    }
    
    func getOTPLabel() -> [String] {
        let label = self.lastPathComponent.removingPercentEncoding
        if label != nil {
            return label!.components(separatedBy: ":")
        } else {
            return []
        }
    }
    
    func getQuery(_ query: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == query })?.value
    }
}
