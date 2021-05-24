//
//  OTPRowView.swift
//  SimpleOTP Mac App
//
//  Created by Kevin Guan on 5/24/21.
//

import SwiftOTP
import SwiftUI

struct OTPRowView: View {
    @EnvironmentObject var model: MainViewModel
    
    let otp: OTP
    
    @Binding var date: Date

    var body: some View {
        Button(action: {
            if let code = getCode() {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(code, forType: .string)
            }
        }) {
            HStack {
                VStack(alignment: .leading) {
                    let code = getCode()
                    
                    if code == nil {
                        Text("Invalid OTP")
                            .font(.system(.headline, design: .monospaced))
                    } else {
                        HStack(spacing: 0) {
                            Text(code!.prefix(code!.count/2))
                                .font(.system(size: 22, design: .monospaced))
                            Text("•")
                            Text(code!.suffix(Int(ceil(Double(code!.count)/2.0))))
                                .font(.system(size: 22, design: .monospaced))
                        }
                    }
                    
                    if otp.issuer != "" {
                        Text(otp.issuer! + " - " + otp.accountname)
                            .font(.system(size: 13, design: .rounded))
                            .lineLimit(2)
                    } else {
                        Text(otp.accountname)
                            .font(.system(size: 13, design: .rounded))
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if otp.type == .totp {
                    TimerView(current: otp.period - Int(date.timeIntervalSince1970) % otp.period, period: otp.period)
                        .padding(.trailing, 5)
                } else {
                    Image(systemName: "play.circle")
                        .font(.system(size: 33.5, weight: .semibold, design: .rounded))
                        .foregroundColor(.blue)
                        .onTapGesture {
                            for i in 0 ..< model.otps.count {
                                if model.otps[i].id == self.otp.id {
                                    model.otps[i].counter += 1
                                }
                            }
                            
                            self.model.saveAllOTPs()
                        }
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func getCode(stringOnly: Bool = false) -> String? {
        return OTPGenerator.getOTPCode(otp: otp, date: date)
    }
}
