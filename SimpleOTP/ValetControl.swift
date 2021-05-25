//
//  ValetControl.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/23/21.
//

import Foundation
import Valet

class ValetControl {
    private static var identifier: SharedGroupIdentifier?
    private static var enableBiometrics: Bool?
    private static var checkPasteboard: Bool?

    static func getSharedGroupIdentifier() -> SharedGroupIdentifier {
        if identifier == nil {
            if let id = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as? String {
                identifier = SharedGroupIdentifier(appIDPrefix: String(id.dropLast()), nonEmptyGroup: "com.kevinguan.simpleOTP")
            }
        }

        assert(identifier != nil)

        return identifier!
    }

    static func getEnableBiometrics() -> Bool {
        if enableBiometrics == nil {
            let valet = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
            if let on = try? valet.string(forKey: "enableBiometrics") {
                enableBiometrics = (on == "1")
            } else {
                enableBiometrics = false // default is false
            }
        }

        assert(enableBiometrics != nil)

        return enableBiometrics!
    }

    static func getCheckPasteboard() -> Bool {
        if checkPasteboard == nil {
            let valet = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
            if let on = try? valet.string(forKey: "checkPasteboard") {
                checkPasteboard = (on == "1")
            } else {
                checkPasteboard = false // default is false
            }
        }

        assert(checkPasteboard != nil)

        return checkPasteboard!
    }

    static func setEnableBiometrics(on: Bool) {
        try? Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked).setString(on ? "1" : "0", forKey: "enableBiometrics")
        enableBiometrics = on
    }

    static func setCheckPasteboard(on: Bool) {
        try? Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked).setString(on ? "1" : "0", forKey: "checkPasteboard")

        checkPasteboard = on
    }
}
