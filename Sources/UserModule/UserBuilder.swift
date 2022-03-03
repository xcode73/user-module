//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 23..
//

@_cdecl("createUserModule")
public func createUserModule() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(UserBuilder()).toOpaque()
}

public final class UserBuilder: FeatherModuleBuilder {

    public override func build() -> FeatherModule {
        UserModule()
    }
}
