//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 01..
//

import UserObjects

extension UserAccountModel {
    
    var list: User.Account.List {
        .init(id: uuid,
              email: email)
    }
    
    var detail: User.Account.Detail {
        .init(id: uuid,
              imageKey: imageKey,
              firstName: firstName,
              lastName: lastName,
              email: email)
    }
    
    func create(_ input: User.Account.Create) {
        imageKey = input.imageKey
        firstName = input.firstName
        lastName = input.lastName
        email = input.email
        password = input.password
    }
    
    func update(_ input: User.Account.Update) {
        imageKey = input.imageKey
        firstName = input.firstName
        lastName = input.lastName
        email = input.email
        password = input.password
    }

    func patch(_ input: User.Account.Patch) {
        imageKey = input.imageKey ?? imageKey
        firstName = input.firstName ?? firstName
        lastName = input.lastName ?? lastName
        email = input.email ?? email
        password = input.password ?? password
    }
}
