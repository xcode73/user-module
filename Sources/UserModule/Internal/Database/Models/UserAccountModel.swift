//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 23..
//

import Foundation
import Feather
import Fluent

final class UserAccountModel: FeatherDatabaseModel {
    typealias Module = UserModule

    struct FieldKeys {
        struct v1 {
            static var imageKey: FieldKey { "image_key" }
            static var firstName: FieldKey { "first_name" }
            static var lastName: FieldKey { "last_name" }
            static var email: FieldKey { "email" }
            static var password: FieldKey { "password" }
        }
    }

    @ID() var id: UUID?
    @Field(key: FieldKeys.v1.imageKey) var imageKey: String?
    @Field(key: FieldKeys.v1.firstName) var firstName: String?
    @Field(key: FieldKeys.v1.lastName) var lastName: String?
    @Field(key: FieldKeys.v1.email) var email: String
    @Field(key: FieldKeys.v1.password) var password: String
    
    init() {}

    init(id: UUID? = nil,
         imageKey: String? = nil,
         firstName: String? = nil,
         lastName: String? = nil,
         email: String,
         password: String)
    {
        self.id = id
        self.imageKey = imageKey
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
    }
}
