//
//  OTPRowView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import SwiftOTP
import SwiftUI

struct OTPRowView: View {
    let otp: OTP
    @Binding var date: Date
    
    // @State var totp: TOTP?
    // @State var hotp: HOTP?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(getCode())
                    .font(.system(.title, design: .monospaced))
                
                if otp.issuer != "" {
                    Text(otp.issuer! + " - " + otp.accountname)
                        .lineLimit(2)
                } else {
                    Text(otp.accountname)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if otp.type == .totp {
                TimerView(current: otp.period - Int(date.timeIntervalSince1970) % otp.period, period: otp.period)
                    .padding(.horizontal, 5)
            } else {
                Button(action: {
                    print("TEST")
                }) {
                    Image(systemName: "play.circle")
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .foregroundColor(.blue)
                }
                .padding(.trailing, -2)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            let pasteboard = UIPasteboard.general
            pasteboard.string = getCode()
        }
    }
    
    func getCode() -> String {
        if otp.type == .totp {
            // if totp == nil {
            guard let data = base32DecodeToData(otp.secret) else { return "Error" }
                
            var alg: OTPAlgorithm
            switch otp.encryptions {
            case .sha1:
                alg = .sha1
            case .sha256:
                alg = .sha256
            case .sha512:
                alg = .sha512
            }
            let totp = TOTP(secret: data, digits: otp.digits, timeInterval: otp.period, algorithm: alg)
            //  }
            
            return totp?.generate(time: date) ?? "Error"
        } else if otp.type == .hotp {
            // if hotp == nil {
            guard let data = base32DecodeToData(otp.secret) else { return "Error" }
                
            var alg: OTPAlgorithm
            switch otp.encryptions {
            case .sha1:
                alg = .sha1
            case .sha256:
                alg = .sha256
            case .sha512:
                alg = .sha512
            }
            let hotp = HOTP(secret: data, digits: otp.digits, algorithm: alg)
            // }
            
            return hotp?.generate(counter: otp.counter) ?? "Error"
        }
        
        return "Error"
    }
}
