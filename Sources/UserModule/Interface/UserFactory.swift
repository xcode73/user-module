//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 23..
//

import Feather

/// user module factory
public struct UserModuleFactory {

    /// build a new module instance using a template
    public static func build(using template: UserModuleTemplate? = nil) -> FeatherModule {
        UserModule(template: template ?? DefaultUserModuleTemplate())
    }
}
