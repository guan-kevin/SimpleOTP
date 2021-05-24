//
//  EncryptionHelper.swift
//  SimpleOTP WatchKit Extension
//
//  Created by Kevin Guan on 5/21/21.
//

import CryptoKit
import Foundation

class EncryptionHelper {
    static func encryptData(otps: [OTP], key: String) -> String? {
        if let data = encodeData(otps) {
            if let encryptedData = try? ChaChaPoly.seal(data, using: getSymmetricKey(password: key)) {
                return encryptedData.combined.base64EncodedString()
            }
        }
        return nil
    }

    static func decryptData(data: String, key: String) -> [OTP]? {
        do {
            let box = try ChaChaPoly.SealedBox(combined: Data(base64Encoded: data) ?? Data())
            let decryptedData = try ChaChaPoly.open(box, using: getSymmetricKey(password: key))
            if let result = decodeData(data: decryptedData, as: [OTP].self) {
                return result
            }
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    static func getSymmetricKey(password: String) -> SymmetricKey {
        return SymmetricKey(data: SHA256.hash(data: password.data(using: .utf8)!))
    }

    static func decodeData<T: Decodable>(data: Data, as type: T.Type) -> T? {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(type, from: data)
            return result
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    static func encodeData<T: Encodable>(_ object: T) -> Data? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            return data
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }
}
