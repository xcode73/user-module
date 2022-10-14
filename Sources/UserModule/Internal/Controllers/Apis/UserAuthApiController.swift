//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 28..
//

import Vapor
import Feather
import FeatherObjects
import UserObjects
import Fluent

extension User.Auth.Response: Content {}

struct UserAuthApiController: AuthController {

    func profileApi(_ req: Request) async throws -> User.Account.Detail {
        guard try await detailProfileAccess(req) else {
            throw Abort(.forbidden)
        }
        guard let user = req.auth.get(FeatherUser.self) else {
            throw Abort(.forbidden)
        }
        guard let account = try await req.user.account.get(user.id) else {
            throw Abort(.notFound)
        }
        return account
    }
    
    func loginApi(req: Request) async throws -> User.Auth.Response {
        guard let guest = req.auth.get(FeatherUser.self), guest.level == .guest else {
            throw Abort(.forbidden)
        }
        guard req.checkPermission("user.profile.login") else {
            throw Abort(.forbidden)
        }

        struct Input: Codable {
            let email: String
            let password: String
        }
                
        try await RequestValidator([
            KeyedContentValidator<String>.required("email"),
            KeyedContentValidator<String>.email("email"),
            KeyedContentValidator<String>.required("password"),
        ]).validate(req)
        
        let input = try req.content.decode(Input.self)
        
        guard
            let model = try await req.user.account.repository.find(input.email),
            let isValid = try? Bcrypt.verify(input.password, created: model.password),
                isValid
        else {
            throw Abort(.forbidden, reason: "Invalid email or password")
        }

        let roles = try await req.user.role.repository.findWithPermissions(model.uuid, req)
        let isRoot = !roles.filter { $0.key == "root" }.isEmpty
        let user = FeatherUser(id: model.uuid,
                               level: isRoot ? .root : .authenticated,
                               roles: roles)
        
        let value = String.generateToken()
        let now = Date()
        let exp = now.addingTimeInterval(86_400 * 7) // one week
        let token = UserTokenModel(value: value, accountId: user.id, lastAccess: now, expiration: exp)
        try await token.create(on: req.db)
        
        guard let account = try await req.user.account.get(user.id) else {
            throw Abort(.notFound)
        }

        return .init(user: user,
                     account: account,
                     token: .init(id: token.uuid, value: token.value, expiration: token.expiration))
    }
    
    func registerApi(req: Request) async throws -> User.Account.Detail {
        guard let guest = req.auth.get(FeatherUser.self), guest.level == .guest else {
            throw Abort(.forbidden)
        }
        let publicRegistrationAccess = try await createProfileAccess(req)
        let invitationAccess = try await createProfileInvitationAccess(req)
        guard publicRegistrationAccess || invitationAccess else {
            throw Abort(.forbidden)
        }
        
        var invitation: UserInvitationModel?
        if invitationAccess && !publicRegistrationAccess {
            guard
                let invitationToken: String = req.query["invitation"],
                !invitationToken.isEmpty,
                let inv = try await UserInvitationModel.query(on: req.db).filter(\.$token == invitationToken).first(),
                inv.expiration > Date()
            else {
                throw Abort(.forbidden)
            }
            invitation = inv
        }
        
        try await RequestValidator(User.Account.Create.validators).validate(req)
        let input = try req.content.decode(User.Account.Create.self)
        let model = UserAccountModel()
        model.create(input)
        model.password = try Bcrypt.hash(input.password)
        try await model.create(on: req.db)
        
        var arguments = ["userId": model.uuid]
        if let id = invitation?.inviterId {
            arguments["inviterId"] = id
        }
        let _: [Void] = try await req.invokeAllAsync(.userRegistration, args: arguments)
        try await invitation?.delete(on: req.db)
        return model.detail
    }
        
    func resetPasswordApi(req: Request) async throws -> HTTPStatus {
        guard try await resetPasswordAccess(req) else {
            throw Abort(.forbidden)
        }

        try await RequestValidator([
            KeyedContentValidator<String>.required("email"),
            KeyedContentValidator<String>.email("email"),
        ]).validate(req)

        let input = try req.content.decode(User.Auth.ResetPasswordRequest.self)
        try await createResetPasswordModel(for: input.email, req: req, isApi: true)
        return .ok
    }
    
    func newPasswordApi(req: Request) async throws -> HTTPStatus {
        guard try await newPasswordAccess(req) else {
            throw Abort(.forbidden)
        }
       
        try await RequestValidator([
            KeyedContentValidator<String>.required("token"),
            KeyedContentValidator<String>.required("password"),
        ]).validate(req)
        
        let input = try req.content.decode(User.Auth.NewPasswordRequest.self)
        try await setNewPassword(input.password, input.token, req)
        return .ok
    }
    
}
