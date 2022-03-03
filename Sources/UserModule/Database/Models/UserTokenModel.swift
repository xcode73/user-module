//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 24..
//

final class UserTokenModel: FeatherDatabaseModel {
    typealias Module = UserModule
        
    struct FieldKeys {
        struct v1 {
            static var value: FieldKey { "value" }
            static var accountId: FieldKey { "account_id" }
            static var expiration: FieldKey { "expiration" }
        }
    }
    
    @ID() var id: UUID?
    @Field(key: FieldKeys.v1.value) var value: String
    @Field(key: FieldKeys.v1.expiration) var expiration: Date
    @Field(key: FieldKeys.v1.accountId) var accountId: UUID

    init() { }
    
    init(id: UUID? = nil,
         value: String,
         accountId: UUID,
         expiration: Date)
    {
        self.id = id
        self.value = value
        self.accountId = accountId
        self.expiration = expiration
    }
}
