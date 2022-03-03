//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 01..
//

import Foundation
import FeatherApi

public extension User {
    
    struct Account: FeatherApiModel {
        public typealias Module = User
    }
}

public extension User.Account {
    
    // MARK: -
    
    struct List: Codable {
        public var id: UUID
        public var email: String
        
        public init(id: UUID,
                    email: String) {
            self.id = id
            self.email = email
        }
    }
    
    // MARK: -
    
    struct Detail: Codable {
        public var id: UUID
        public var imageKey: String?
        public var firstName: String?
        public var lastName: String?
        public var email: String
        
        public init(id: UUID,
                    imageKey: String?,
                    firstName: String?,
                    lastName: String?,
                    email: String) {
            self.id = id
            self.imageKey = imageKey
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
        }
    }
    
    // MARK: -
    
    struct Create: Codable {
        public var imageKey: String?
        public var firstName: String?
        public var lastName: String?
        public var email: String
        public var password: String
        public var isRoot: Bool
        
        public init(imageKey: String? = nil,
                    firstName: String? = nil,
                    lastName: String? = nil,
                    email: String,
                    password: String,
                    isRoot: Bool = false) {
            self.imageKey = imageKey
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.password = password
            self.isRoot = isRoot
        }
    }
    
    // MARK: -
    
    struct Update: Codable {
        public var imageKey: String?
        public var firstName: String?
        public var lastName: String?
        public var email: String
        public var password: String
        public var isRoot: Bool
        
        public init(imageKey: String? = nil,
                    firstName: String? = nil,
                    lastName: String? = nil,
                    email: String,
                    password: String,
                    isRoot: Bool = false) {
            self.imageKey = imageKey
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.password = password
            self.isRoot = isRoot
        }
    }
    
    // MARK: -
    
    struct Patch: Codable {
        public var imageKey: String?
        public var firstName: String?
        public var lastName: String?
        public var email: String?
        public var password: String?
        public var isRoot: Bool?
        
        public init(imageKey: String? = nil,
                    firstName: String? = nil,
                    lastName: String? = nil,
                    email: String? = nil,
                    password: String? = nil,
                    isRoot: Bool? = nil) {
            self.imageKey = imageKey
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.password = password
            self.isRoot = isRoot
        }
    }
}
