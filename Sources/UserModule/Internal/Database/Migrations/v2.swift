//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 10. 14..
//

import Fluent

extension UserMigrations {

    struct v2: AsyncMigration {
        
        func prepare(on db: Database) async throws {
            try await db.schema(UserTokenModel.schema)
                .field(UserTokenModel.FieldKeys.v2.lastAccess, .datetime, .required)
                .update()
            
            try await db.schema(UserAccountModel.schema)
                .field(UserAccountModel.FieldKeys.v2.lastAccess, .datetime)
                .update()
        }
        
        func revert(on db: Database) async throws {
            try await db.schema(UserAccountModel.schema)
                .deleteField(UserAccountModel.FieldKeys.v2.lastAccess)
                .update()
            
            try await db.schema(UserTokenModel.schema)
                .deleteField(UserTokenModel.FieldKeys.v2.lastAccess)
                .update()
        }
    }
}
