//
//  File.swift
//  Networking
//
//  Created by Deniz Kaplan on 10.11.2025.
//

import Foundation

public extension HTTPURLResponse {
    var attemptsLeftHeader: Int? {
        allHeaderFields["Ratelimit-Attempts-Left"] as? Int
    }
    
    var retryAfterHeader: TimeInterval? {
        allHeaderFields["Ratelimit-Retry-After"] as? TimeInterval
    }
}
