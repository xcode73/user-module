//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 23..
//

import SwiftSgml
import Feather

public protocol UserModuleTemplate: FeatherTemplate {
    func login(_ context: UserLoginContext) -> AbstractTemplate<UserLoginContext>
}
