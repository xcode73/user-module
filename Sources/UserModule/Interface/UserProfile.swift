//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 27..
//

import FeatherObjects
import UserObjects

public extension User {
    
    struct Profile: FeatherObjectModel {
        public typealias Module = User
    }
}
