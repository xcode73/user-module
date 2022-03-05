//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 01..
//

import UserApi

extension UserRoleModel {

    var list: User.Role.List {
        .init(id: uuid, key: key, name: name)
    }
    
    var detail: User.Role.Detail {
        .init(id: uuid, key: key, name: name, notes: notes)
    }
    
    func create(_ input: User.Role.Create) {
        key = input.key
        name = input.name
        notes = input.notes
    }
    
    func update(_ input: User.Role.Update) {
        key = input.key
        name = input.name
        notes = input.notes
    }

    func patch(_ input: User.Role.Patch) {
        key = input.key ?? key
        name = input.name ?? name
        notes = input.notes ?? notes
    }
}
