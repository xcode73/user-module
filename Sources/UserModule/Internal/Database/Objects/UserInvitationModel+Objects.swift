//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 27..
//

import UserObjects

extension UserInvitationModel {
    
    var list: User.Invitation.List {
        .init(id: uuid,
              email: email,
              token: token,
              expiration: expiration,
              inviterId: inviterId)
    }
    
    var detail: User.Invitation.Detail {
        .init(id: uuid,
              email: email,
              token: token,
              expiration: expiration,
              inviterId: inviterId)
    }
    
    func create(_ input: User.Invitation.Create) {
        email = input.email
    }
    
    func update(_ input: User.Invitation.Update) {
        email = input.email
    }

    func patch(_ input: User.Invitation.Patch) {
        email = input.email ?? email
    }
}
