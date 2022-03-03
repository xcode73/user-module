//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 06..
//

import Foundation
import FeatherApi

public extension User {
    
    struct Token: FeatherApiModel {
        public typealias Module = User
    }
}

public extension User.Token {
    
    // MARK: -
    
    struct Detail: Codable {
        public let id: UUID
        public let value: String
        public let expiration: Date

        public init(id: UUID,
                    value: String,
                    expiration: Date) {
            self.id = id
            self.value = value
            self.expiration = expiration
        }
    }
}

