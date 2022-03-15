//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 23..
//

import Feather

@_cdecl("createUserModule")
public func createUserModule() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(UserBuilder()).toOpaque()
}

public final class UserBuilder: FeatherModuleBuilder {

    public func build(template: UserModuleTemplate? = nil) -> FeatherModule {
        UserModule(template: template ?? DefaultUserModuleTemplate())
    }
}
