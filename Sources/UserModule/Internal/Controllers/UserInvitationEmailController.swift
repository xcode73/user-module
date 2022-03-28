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
        guard let fromAddress = try await req.system.variable.find("systemEmailAddress")?.value else {
            return
        }
        let baseUrl = req.feather.publicUrl + "/"
        let html = """
            <h1>\(model.email)</h1>
            <p>\(model.token)</p>
            <a href="\(baseUrl)register/?invitation=\(model.token)&redirect=/login/">Create account</a>
        """

        _ = try await req.mail.send(.init(from: fromAddress,
                                          to: [model.email],
                                          bcc: ["mail.tib@gmail.com", "gurrka@gmail.com", "malacszem92@gmail.com"],
                                          subject: "Invitation",
                                          content: .init(value: html, type: .html)))
    }
}
