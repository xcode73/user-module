//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 27..
//

import Feather
import Vapor
import Fluent
import FeatherObjects
import UserObjects

extension User.Token.Detail: Content {}

struct UserAuthController: AuthController {
    
    // MARK: - private
    
    private func render(_ req: Request, form: UserLoginForm) -> Response {
        let ctx = UserLoginContext(title: "Sign in",
                                   message: "Please enter your user credentials to sign in.",
                                   links: [
                                    .init(label: "Forgot your password?",
                                          path: "/reset-password/?redirect=/login/",
                                          absolute: true,
                                          permission: "user.profile.reset-password"),
                                    .init(label: "Create account",
                                          path: "/register/?redirect=/login/",
                                          absolute: true,
                                          permission: "user.profile.create"),
                                   ],
                                   form: form.context(req))
        let template = req.templateEngine.user.login(ctx)
        return req.templates.renderHtml(template)
    }

    private func getCustomRedirect(_ req: Request) -> String {
        if let customRedirect: String = req.query["redirect"], !customRedirect.isEmpty {
            return customRedirect.safePath()
        }
        return "/"
    }
    
    // MARK: - api

    func loginView(_ req: Request) async throws -> Response {
        guard let user = req.auth.get(FeatherUser.self), user.level == .guest else {
            return req.redirect(to: getCustomRedirect(req))
        }
        guard req.checkPermission("user.profile.login") else {
            return req.redirect(to: getCustomRedirect(req))
        }
        
        let form = UserLoginForm()
        form.fields = form.createFields(req)
        try await form.load(req: req)
        return render(req, form: form)
    }

    func login(_ req: Request) async throws -> Response {
        guard let guest = req.auth.get(FeatherUser.self), guest.level == .guest else {
            return req.redirect(to: getCustomRedirect(req))
        }
        guard req.checkPermission("user.profile.login") else {
            return req.redirect(to: getCustomRedirect(req))
        }

        let form = UserLoginForm()
        form.fields = form.createFields(req)
        try await form.load(req: req)
        try await form.process(req: req)
        guard try await form.validate(req: req) else {
            return render(req, form: form)
        }
        try await form.write(req: req)

        guard
            let model = try await req.user.account.repository.find(form.email),
            try Bcrypt.verify(form.password, created: model.password)
        else {
            form.error = "Invalid email or password"
            return render(req, form: form)
        }

        let roles = try await req.user.role.repository.findWithPermissions(model.uuid, req)
        let isRoot = !roles.filter { $0.key == "root" }.isEmpty
        let user = FeatherUser(id: model.uuid,
                               level: isRoot ? .root : .authenticated,
                               roles: roles)
        req.auth.login(user)
        req.session.authenticate(user)
        return req.redirect(to: getCustomRedirect(req))
    }
    
    func logout(_ req: Request) async throws -> Response {
        guard req.checkPermission("user.profile.logout") else {
            return req.redirect(to: getCustomRedirect(req))
        }
        req.auth.logout(FeatherUser.self)
        req.session.unauthenticate(FeatherUser.self)
        return req.redirect(to: getCustomRedirect(req))
    }
    
    // MARK: - private
    
    private func renderRegisterForm(_ req: Request, form: UserRegisterForm) -> Response {
        let template = UserRegisterTemplate(.init(title: "Create account",
                                                  message: "Register a new user account",
                                                  form: form.context(req)))
        return req.templates.renderHtml(template)
    }

    
    // MARK: - api

    func registerView(_ req: Request) async throws -> Response {
        guard let guest = req.auth.get(FeatherUser.self), guest.level == .guest else {
            return req.redirect(to: getCustomRedirect(req))
        }
        let publicRegistrationAccess = try await createProfileAccess(req)
        let invitationAccess = try await createProfileInvitationAccess(req)
        guard publicRegistrationAccess || invitationAccess else {
            throw Abort(.forbidden)
        }

        var invitation: UserInvitationModel?
        guard
            let invitationToken: String = req.query["invitation"],
            !invitationToken.isEmpty,
            let inv = try await UserInvitationModel.query(on: req.db).filter(\.$token == invitationToken).first(),
            inv.expiration > Date()
        else {
            throw Abort(.badRequest)
        }
        invitation = inv
        
        let form = UserRegisterForm()
        form.fields = form.createFields(req)
        form.email = invitation?.email ?? ""

        try await form.load(req: req)
        try await form.read(req: req)
        return renderRegisterForm(req, form: form)
    }

    func register(_ req: Request) async throws -> Response {
        guard let guest = req.auth.get(FeatherUser.self), guest.level == .guest else {
            return req.redirect(to: getCustomRedirect(req))
        }
        let publicRegistrationAccess = try await createProfileAccess(req)
        let invitationAccess = try await createProfileInvitationAccess(req)
        guard publicRegistrationAccess || invitationAccess else {
            throw Abort(.forbidden)
        }
        
        var invitation: UserInvitationModel?

        guard
            let invitationToken: String = req.query["invitation"],
            !invitationToken.isEmpty,
            let inv = try await UserInvitationModel.query(on: req.db).filter(\.$token == invitationToken).first(),
            inv.expiration > Date()
        else {
            throw Abort(.badRequest)
        }
        invitation = inv
        
        let form = UserRegisterForm()
        form.fields = form.createFields(req)
        form.email = invitation?.email ?? ""
        
        try await form.load(req: req)
        try await form.read(req: req)
        try await form.process(req: req)
        guard try await form.validate(req: req) else {
            return renderRegisterForm(req, form: form)
        }
        try await form.write(req: req)
        let model = UserAccountModel(id: UUID(),
                                     imageKey: form.imageKey,
                                     firstName: form.firstName,
                                     lastName: form.lastName,
                                     email: form.email,
                                     password: try Bcrypt.hash(form.password))
        
        try await model.create(on: req.db)
        
        var arguments = ["userId": model.uuid]
        if let id = invitation?.inviterId {
            arguments["inviterId"] = id
        }
        let _: [Void] = try await req.invokeAllAsync(.userRegistration, args: arguments)
        
        try await invitation?.delete(on: req.db)

        return req.redirect(to: "/login/")
    }
    
    // MARK: - forget password
    
    private func renderResetPasswordForm(_ req: Request, form: UserResetPasswordForm) -> Response {
        let template = UserResetPasswordTemplate(.init(title: "Forgot your password?",
                                                       message: "No worries, we'll send you reset instructions.",
                                                       link: .init(label: "Sign in",
                                                                   path: "/login/",
                                                                   absolute: true,
                                                                   permission: "user.profile.login"),
                                                       form: form.context(req)))
        return req.templates.renderHtml(template)
    }
    
    func resetPasswordView(_ req: Request) async throws -> Response {
        guard let guest = req.auth.get(FeatherUser.self), guest.level == .guest else {
            return req.redirect(to: getCustomRedirect(req))
        }
        guard try await resetPasswordAccess(req) else {
            throw Abort(.forbidden)
        }
        let form = UserResetPasswordForm()
        form.fields = form.createFields(req)
        try await form.load(req: req)
        return renderResetPasswordForm(req, form: form)
    }

    func resetPassword(_ req: Request) async throws -> Response {
        guard let guest = req.auth.get(FeatherUser.self), guest.level == .guest else {
            return req.redirect(to: getCustomRedirect(req))
        }
        guard try await resetPasswordAccess(req) else {
            throw Abort(.forbidden)
        }

        let form = UserResetPasswordForm()
        form.fields = form.createFields(req)
        try await form.load(req: req)
        try await form.process(req: req)
        guard try await form.validate(req: req) else {
            return renderResetPasswordForm(req, form: form)
        }
        try await form.write(req: req)
        
        try await createResetPasswordModel(for: form.email, req: req)
        return req.redirect(to: getCustomRedirect(req))
    }
    
    // MARK: - new password
    
    private func renderNewPasswordForm(_ req: Request, form: UserNewPasswordForm) -> Response {
        let template = UserRegisterTemplate(.init(title: "Set new password",
                                                  message: "Pick a new password for your account",
                                                  form: form.context(req)))
        return req.templates.renderHtml(template)
    }
    
    func newPasswordView(_ req: Request) async throws -> Response {
        guard let guest = req.auth.get(FeatherUser.self), guest.level == .guest else {
            return req.redirect(to: getCustomRedirect(req))
        }
        guard try await newPasswordAccess(req) else {
            throw Abort(.forbidden)
        }
        guard
            let token = req.getQuery("token"),
            try await UserResetPasswordModel.query(on: req.db).filter(\.$token == token).count() == 1
        else {
            throw Abort(.forbidden, reason: "Invalid token")
        }
        let form = UserNewPasswordForm()
        form.fields = form.createFields(req)
        try await form.load(req: req)
        return renderNewPasswordForm(req, form: form)
    }

    func newPassword(_ req: Request) async throws -> Response {
        guard let guest = req.auth.get(FeatherUser.self), guest.level == .guest else {
            return req.redirect(to: getCustomRedirect(req))
        }
        guard try await newPasswordAccess(req) else {
            throw Abort(.forbidden)
        }

        guard let token = req.getQuery("token") else {
            throw Abort(.forbidden, reason: "Missing token")
        }
        
        let form = UserNewPasswordForm()
        form.fields = form.createFields(req)
        try await form.load(req: req)
        try await form.process(req: req)
        guard try await form.validate(req: req) else {
            return renderNewPasswordForm(req, form: form)
        }
        try await form.write(req: req)

        try await setNewPassword(form.password, token, req)

        return req.redirect(to: getCustomRedirect(req))
    }
}
