//
//  SettingsViewModel.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/18/21.
//

import Foundation
import LocalAuthentication
import Valet

final class SettingsViewModel: ObservableObject {
    func getBiometricType() -> String? {
        let laContext = LAContext()

        var error: NSError?
        guard laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return nil
        }

        if laContext.biometryType == .faceID {
            return "Face ID"
        } else {
            return "Touch ID"
        }
    }
}
