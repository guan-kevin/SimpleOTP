//
//  ValetControl.swift
//  SimpleOTP Mac App
//
//  Created by Kevin Guan on 5/24/21.
//

import Foundation
import Valet

class ValetControl {
    static var identifier: SharedGroupIdentifier?

    static func getSharedGroupIdentifier() -> SharedGroupIdentifier {
        if identifier == nil {
            if let id = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as? String {
                identifier = SharedGroupIdentifier(appIDPrefix: String(id.dropLast()), nonEmptyGroup: "com.kevinguan.simpleOTP")
            }
        }

        assert(identifier != nil)

        return identifier!
    }
}
