//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

import Feather
import Fluent

final class UserResetPasswordModel: FeatherDatabaseModel {
    typealias Module = UserModule
    
    struct FieldKeys {
        struct v1 {
            static var accountId: FieldKey { "account_id" }
            static var token: FieldKey { "token" }
            static var expiration: FieldKey { "expiration" }
        }
    }

    @ID() var id: UUID?
    @Field(key: FieldKeys.v1.accountId) var accountId: UUID
    @Field(key: FieldKeys.v1.token) var token: String
    @Field(key: FieldKeys.v1.expiration) var expiration: Date

    init() { }
    
    init(id: UUID? = nil,
         accountId: UUID,
         token: String,
         expiration: Date) {
        self.id = id
        self.accountId = accountId
        self.token = token
        self.expiration = expiration
    }
}
