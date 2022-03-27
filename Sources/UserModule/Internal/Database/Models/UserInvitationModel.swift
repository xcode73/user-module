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
            static var token: FieldKey { "token" }
            static var expiration: FieldKey { "expiration" }
            static var inviterId: FieldKey { "inviter_id" }
        }
    }
    
    @ID() var id: UUID?
    @Field(key: FieldKeys.v1.email) var email: String
    @Field(key: FieldKeys.v1.token) var token: String
    @Field(key: FieldKeys.v1.expiration) var expiration: Date
    @Field(key: FieldKeys.v1.inviterId) var inviterId: UUID

    init() { }
    
    init(id: UUID? = nil,
         email: String,
         token: String,
         expiration: Date,
         inviterId: UUID)
    {
        self.id = id
        self.email = email
        self.token = token
        self.expiration = expiration
        self.inviterId = inviterId
    }
}
