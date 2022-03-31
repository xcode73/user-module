//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

import Vapor
import Fluent
import Feather

struct UserTokenRepository: FeatherModelRepository {
    typealias DatabaseModel = UserTokenModel

    private(set) var db: Database
    
    init(_ db: Database) {
        self.db = db
    }
}
