//
//  MainViewModel.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/16/21.
//

import Foundation
import LocalAuthentication
import Valet

final class MainViewModel: ObservableObject {
    @Published var isLocked = true

    var valet: Valet?
    @Published var otps: [OTP] = []

    init() {
        print("INIT")
        valet = Valet.valet(with: Identifier(nonEmpty: "com.kevinguan.simpleOTP")!, accessibility: .whenUnlocked)
        list()
    }

    func list() {
        if valet != nil {
            if let data = try? valet!.object(forKey: "otps") {
                otps = decodeData(data: data, as: [OTP].self) ?? []
            }
        }
    }

    func addOTP(otp: OTP) {
        otps.append(otp)
        if valet != nil {
            do {
                if let data = encodeData(otps) {
                    try valet?.setObject(data, forKey: "otps")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func decodeData<T: Decodable>(data: Data, as type: T.Type) -> T? {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(type, from: data)
            return result
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    func encodeData<T: Encodable>(_ object: T) -> Data? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            return data
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    func isAppLocked() -> Bool {
        return isLocked
    }

    func unlockApp() {
        let laContext = LAContext()
        let reason = "Lock SimpleOTP"
        laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.isLocked = false
                }
            } else {
                if let error = error as? LAError {
                    DispatchQueue.main.async {
                        print(error.localizedDescription)

                        if error.code == .biometryLockout {
                            // try again without biometrics

                            laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                                if success {
                                    DispatchQueue.main.async {
                                        self.isLocked = false
                                    }
                                } else {
                                    print("Not able to open the app anymore!")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
