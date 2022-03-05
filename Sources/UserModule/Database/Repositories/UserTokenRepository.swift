//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

import Vapor
import Feather

struct UserTokenRepository: FeatherModelRepository {
    typealias DatabaseModel = UserTokenModel

    public private(set) var req: Request
    
    init(_ req: Request) {
        self.req = req
    }
}
