//
//  model.swift
//  webview
//
//  Created by 김태현 on 8/1/24.
//

import Foundation

class TestModel: Codable {
    let name: String
    let identity: String
    let agency: String
    let phoneNumber: String
    
    init(name: String, identity: String, agency: String, phoneNumber: String) {
        self.name = name
        self.identity = identity
        self.agency = agency
        self.phoneNumber = phoneNumber
    }
}
