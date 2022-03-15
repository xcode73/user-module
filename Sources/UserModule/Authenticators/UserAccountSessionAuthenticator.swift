//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 11. 24..
//

import Vapor
import Feather
import FeatherApi
import UserApi

struct UserAccountSessionAuthenticator: AsyncSessionAuthenticator {
    typealias User = FeatherUser

    /// override session authenticator, we don't care if the user is logged in or not, we always log in
    func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        if let sessionId = req.session.authenticated(User.self) {
            try await self.authenticate(sessionID: sessionId, for: req)
        }

        let response = try await next.respond(to: req)
        if let user = req.auth.get(User.self) {
            req.session.authenticate(user)
        }
        else if req.hasSession {
            req.session.unauthenticate(User.self)
        }
        return response
    }
    
    func authenticate(sessionID: UUID, for req: Request) async throws {
        guard let model = try await req.user.account.repository.get(sessionID) else {
            return
        }
        let roles = try await req.user.role.repository.findWithPermissions(model.uuid)
        let isRoot = !roles.filter { $0.key == UserApi.User.Role.Keys.Root }.isEmpty
        return req.auth.login(FeatherUser(id: model.uuid, level: isRoot ? .root : .authenticated, roles: roles))
    }
}
