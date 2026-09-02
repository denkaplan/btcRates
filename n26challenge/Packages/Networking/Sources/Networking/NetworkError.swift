//
//  File.swift
//  Networking
//
//  Created by Kaplan, Deniz on 02.09.26.
//

import Foundation

public enum NetworkError: LocalizedError {
    case unknown
    case badRequest
    case http(Int)
    case decoding(DecodingError)
    case noInternet
    case timeout
}
