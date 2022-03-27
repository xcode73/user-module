//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 27..
//

import Foundation
import Feather
import UserObjects

public struct UserProfileApi {

    let repository: UserAccountRepository
    
    init(_ repository: UserAccountRepository) {
        self.repository = repository
    }
}

public extension UserProfileApi {

//    func list() async throws -> [User.Account.List] {
//        try await repository.list().transform(to: [User.Account.List].self)
//    }

}
