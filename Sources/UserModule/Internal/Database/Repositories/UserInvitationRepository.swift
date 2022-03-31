//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 27..
//

import Feather
import Vapor
import Fluent
import FeatherObjects

struct UserInvitationRepository: FeatherModelRepository {
    typealias DatabaseModel = UserInvitationModel
    
    private(set) var db: Database
    
    init(_ db: Database) {
        self.db = db
    }
}

extension UserInvitationRepository {
    
//    func find(_ key: String) async throws -> DatabaseModel? {
//        try await query().filter(\.$key == key).first()
//    }
    
}
