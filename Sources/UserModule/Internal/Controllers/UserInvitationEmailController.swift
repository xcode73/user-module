//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 28..
//

import Vapor
import Mail

struct UserInvitationEmailController {
    
    func send(_ req: Request, _ model: UserInvitationModel) async throws {
        let baseUrl = req.feather.publicUrl + "/"
        let html = """
        <h1>Hello.</h1>
        <p>You've been invited to the site \(baseUrl) with the following email address: \(model.email).</p>
        <p>You can accept this invitation and create a new account by clicking the link below:</p>

        <p><a href="\(baseUrl)register/?invitation=\(model.token)&redirect=/login/">Create new account</a></p>
        
        <p>If you did not request the invitation, feel free to ignore this email.</p>
        <p>Invitation links will expire in 24 hours.</p>
        """
        guard let from = req.variable("systemEmailAddress") else {
            return
        }
        
        var bcc: [String] = []
        if let rawBcc = req.variable("systemBccEmailAddresses") {
            bcc = rawBcc.components(separatedBy: ",")
        }
        
        _ = try await req.mail.send(.init(from: from,
                                          to: [model.email],
                                          bcc: bcc,
                                          subject: "Invitation",
                                          content: .init(value: html, type: .html)))
    }
}
