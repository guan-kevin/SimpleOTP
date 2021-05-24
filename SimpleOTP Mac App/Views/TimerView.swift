//
//  TimerView.swift
//  SimpleOTP Mac App
//
//  Created by Kevin Guan on 5/24/21.
//

import SwiftUI

struct TimerView: View {
    var current: Int
    var period: Int

    var body: some View {
        Group {
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .opacity(0.2)
                    .foregroundColor(current > 7 ? Color.blue : Color.red)

                Circle()
                    .trim(from: 0.0, to: CGFloat(min(Double(current) / Double(period), 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .foregroundColor(current > 7 ? Color.blue : Color.red)
                    .rotationEffect(Angle(degrees: -90))
                Text(String(current))
                    .font(.system(size: 13, design: .monospaced))
                    .lineLimit(1)
            }
        }
        .frame(width: 30)
    }
}
