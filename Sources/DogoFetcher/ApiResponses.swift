//
//  File.swift
//  
//
//  Created by Denislava Shentova on 24.01.23.
//

import Foundation

protocol SingleMessgaeResponse: Codable {
    var message: String { get }
}

protocol MessageArrayResponse: Codable {
    var message: [String] { get }
}

struct SingleDogoResponse: SingleMessgaeResponse {
    let message: String
}

struct ManyDogosResponse: MessageArrayResponse {
    let message: [String]
}
