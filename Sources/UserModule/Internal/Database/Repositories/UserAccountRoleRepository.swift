//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 31..
//

import Vapor
import Fluent
import Feather

struct UserAccountRoleRepository: FeatherModelRepository {
    typealias DatabaseModel = UserAccountRoleModel

    public private(set) var db: Database
    
    init(_ db: Database) {
        self.db = db
    }
}

extension UserAccountRoleRepository {


}
