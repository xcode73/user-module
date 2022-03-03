//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

struct UserResetPasswordRepository: FeatherModelRepository {
    typealias DatabaseModel = UserResetPasswordModel

    public private(set) var req: Request
    
    init(_ req: Request) {
        self.req = req
    }
}
