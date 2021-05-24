//
//  MainViewModel.swift
//  SimpleOTP Mac App
//
//  Created by Kevin Guan on 5/23/21.
//

import Foundation
import Valet

final class MainViewModel: ObservableObject {
    var valet: Valet?

    @Published var otps: [OTP] = []

    init() {
        print("INIT")
        valet = Valet.iCloudSharedGroupValet(with: ValetControl.getSharedGroupIdentifier(), accessibility: .whenUnlocked)
    }

    func list() {
        if valet != nil {
            if let data = try? valet!.object(forKey: "otps") {
                otps = EncryptionHelper.decodeData(data: data, as: [OTP].self) ?? []
            }
        }
    }

    func saveAllOTPs() {
        if valet != nil {
            do {
                if let data = EncryptionHelper.encodeData(otps) {
                    try valet?.setObject(data, forKey: "otps")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
