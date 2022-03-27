//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 27..
//

import Foundation
import FeatherObjects
import UserObjects

public extension User {
    
    struct Invitation: FeatherObjectModel {
        public typealias Module = User
    }
}

public extension User.Invitation {
    
    // MARK: -
    
    struct List: Codable {
        public var id: UUID
        public var email: String
        public var token: String
        public var expiration: Date
        public var inviterId: UUID
        
        public init(id: UUID,
                    email: String,
                    token: String,
                    expiration: Date,
                    inviterId: UUID) {
            self.id = id
            self.email = email
            self.token = token
            self.expiration = expiration
            self.inviterId = inviterId
        }
    }
    
    // MARK: -
    
    struct Detail: Codable {
        public var id: UUID
        public var email: String
        public var token: String
        public var expiration: Date
        public var inviterId: UUID
        
        public init(id: UUID,
                    email: String,
                    token: String,
                    expiration: Date,
                    inviterId: UUID) {
            self.id = id
            self.email = email
            self.token = token
            self.expiration = expiration
            self.inviterId = inviterId
        }
    }
    
    // MARK: -
    
    struct Create: Codable {
        public var email: String
        public var token: String?
        public var expiration: Date?
        
        public init(email: String,
                    token: String? = nil,
                    expiration: Date? = nil) {
            self.email = email
            self.token = token
            self.expiration = expiration
        }
    }
    
    // MARK: -
    
    struct Update: Codable {
        public var email: String
        public var token: String
        public var expiration: Date
        
        public init(email: String,
                    token: String,
                    expiration: Date) {
            self.email = email
            self.token = token
            self.expiration = expiration
        }
    }
    
    // MARK: -
    
    struct Patch: Codable {
        public var email: String?
        public var token: String?
        public var expiration: Date?
        
        public init(email: String? = nil,
                    token: String? = nil,
                    expiration: Date? = nil) {
            self.email = email
            self.token = token
            self.expiration = expiration
        }
    }
}
