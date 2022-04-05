//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 01..
//

import Vapor
import Fluent
import Feather
import Mail

//extension Request {
//    var hostname: String? {
//        return headers.forwarded.first?.for ?? headers.first(name: .xForwardedFor) ?? remoteAddress?.hostname
//    }
//}


protocol AuthController {
    
}

extension AuthController {
    
    func createProfileAccess(_ req: Request) async throws -> Bool {
        try await req.checkAccess(for: .init("user.profile.create"))
    }
    
    func createProfileInvitationAccess(_ req: Request) async throws -> Bool {
        try await req.checkAccess(for: .init("user.profile.invitation"))
    }

    func detailProfileAccess(_ req: Request) async throws -> Bool {
        try await req.checkAccess(for: .init("user.profile.detail"))
    }
    
    func updateProfileAccess(_ req: Request) async throws -> Bool {
        try await req.checkAccess(for: .init("user.profile.update"))
    }
    
    func patchProfileAccess(_ req: Request) async throws -> Bool {
        try await req.checkAccess(for: .init("user.profile.patch"))
    }
    
    func deleteProfileAccess(_ req: Request) async throws -> Bool {
        try await req.checkAccess(for: .init("user.profile.delete"))
    }    
    
    func resetPasswordAccess(_ req: Request) async throws -> Bool {
        try await req.checkAccess(for: .init("user.profile.reset-password"))
    }
    
    func newPasswordAccess(_ req: Request) async throws -> Bool {
        try await req.checkAccess(for: .init("user.profile.new-password"))
    }
    

    func createResetPasswordModel(for email: String, req: Request, isApi: Bool = false) async throws {
        let user = try await UserAccountModel.query(on: req.db).filter(\.$email == email).first()
        guard let user = user else {
            return
        }
        
        try await UserResetPasswordModel.query(on: req.db).filter(\.$accountId == user.uuid).delete()
        let model = UserResetPasswordModel(id: UUID(),
                                         accountId: user.uuid,
                                         token: String.generateToken(),
                                         expiration: Date().addingTimeInterval(86_400)) // one day

        try await model.create(on: req.db)

        var baseUrl = req.feather.publicUrl + "/"
        if isApi, let scheme = try await req.system.variable.find("systemDeepLinkScheme")?.value {
            baseUrl = scheme + "://"
        }

        let html = """
        <h1>Hello.</h1>
        <p>We've received a request to reset the password for the account at \(baseUrl) associated with \(user.email).</p>
        <p>No changes have been made to your account yet. You can reset your password by clicking the link below:</p>

        <p><a href="\(baseUrl)new-password?token=\(model.token)&redirect=/login/">Reset your password</a></p>
        
        <p>If you did not request a new password, please let us know immediately.</p>
        """

        guard let from = req.variable("systemEmailAddress") else {
            return
        }
        
        var bcc: [String] = []
        if let rawBcc = req.variable("systemBccEmailAddresses") {
            bcc = rawBcc.components(separatedBy: ",")
        }
        
        _ = try await req.mail.send(.init(from: from,
                                          to: [user.email],
                                          bcc: bcc,
                                          subject: "Password reset",
                                          content: .init(value: html, type: .html)))
    }
    
    func setNewPassword(_ password: String, _ t: String, _ req: Request) async throws {
        guard let token = try await UserResetPasswordModel.query(on: req.db).filter(\.$token == t).first() else {
            throw Abort(.notFound, reason: "Invalid token")
        }
        
        let now = Date()
        guard token.expiration > now else {
            throw Abort(.badRequest, reason: "Token is expired")
        }

        guard let account = try await req.user.account.repository.get(token.accountId) else {
            throw Abort(.notFound, reason: "Account not found")
        }
        account.password = try Bcrypt.hash(password)

        try await req.db.transaction { db in
            try await account.update(on: db)
            try await token.delete(on: db)
        }
    }
}
