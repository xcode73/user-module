//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 03. 01..
//


protocol AuthController {
    
}

extension AuthController {
    
    func createProfileAccess(_ req: Request) async throws -> Bool {
        try await req.checkAccess(for: .init("user.profile.create"))
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
    

    func createResetPasswordModel(for email: String, req: Request) async throws {
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
        
        // TODO: check if has suffix
        var baseUrl = req.feather.baseUrl + "/"
        if let scheme = try await req.system.variable.find("systemDeepLinkScheme")?.value {
            baseUrl = scheme + "://"
        }

        let html = """
            <h1>\(user.email)</h1>
            <p>\(model.token)</p>
            <a href="\(baseUrl)new-password?token=\(model.token)">Password reset link</a>
        """

        _ = try await req.mail.send(.init(from: "noreply@feathercms.com",
                                          to: [user.email],
                                          cc: ["mail.tib@gmail.com", "gurrka@gmail.com", "malacszem92@gmail.com"],
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
