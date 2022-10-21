//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 24..
//

import Foundation
import Feather
import Fluent

final class UserTokenModel: FeatherDatabaseModel {
    typealias Module = UserModule
        
    struct FieldKeys {
        struct v1 {
            static var value: FieldKey { "value" }
            static var accountId: FieldKey { "account_id" }
            static var expiration: FieldKey { "expiration" }
        }
        struct v2 {
            static var lastAccess: FieldKey { "last_access" }
        }
    }
    
    @ID() var id: UUID?
    @Field(key: FieldKeys.v1.value) var value: String
    @Field(key: FieldKeys.v1.expiration) var expiration: Date
    @Field(key: FieldKeys.v2.lastAccess) var lastAccess: Date
    @Field(key: FieldKeys.v1.accountId) var accountId: UUID

    init() {}
    
    init(id: UUID? = nil,
         value: String,
         accountId: UUID,
         lastAccess: Date,
         expiration: Date)
    {
        self.id = id
        self.value = value
        self.accountId = accountId
        self.lastAccess = lastAccess
        self.expiration = expiration
    }
}
