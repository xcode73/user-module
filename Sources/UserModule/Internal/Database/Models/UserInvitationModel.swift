//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 25..
//

import Foundation
import Feather
import Fluent

final class UserInvitationModel: FeatherDatabaseModel {
    typealias Module = UserModule
        
    struct FieldKeys {
        struct v1 {
            static var email: FieldKey { "email" }
            static var value: FieldKey { "value" }
            static var expiration: FieldKey { "expiration" }
        }
    }
    
    @ID() var id: UUID?
    @Field(key: FieldKeys.v1.email) var email: String
    @Field(key: FieldKeys.v1.value) var value: String
    @Field(key: FieldKeys.v1.expiration) var expiration: Date

    init() { }
    
    init(id: UUID? = nil,
         email: String,
         value: String,
         expiration: Date)
    {
        self.id = id
        self.email = email
        self.value = value
        self.expiration = expiration
    }
}
