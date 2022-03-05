//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2021. 12. 06..
//

import Vapor
import Feather
import UserApi

extension User.Role.List: Content {}
extension User.Role.Detail: Content {}

struct UserRoleApiController: ApiController {
    typealias ApiModel = User.Role
    typealias DatabaseModel = UserRoleModel

    func listOutput(_ req: Request, _ models: [DatabaseModel]) async throws -> [User.Role.List] {
        models.map(\.list)
    }
    
    func detailOutput(_ req: Request, _ model: DatabaseModel) async throws -> User.Role.Detail {
        model.detail
    }
    
    func createInput(_ req: Request, _ model: DatabaseModel, _ input: User.Role.Create) async throws {
        model.create(input)
    }
    
    func updateInput(_ req: Request, _ model: DatabaseModel, _ input: User.Role.Update) async throws {
        model.update(input)
    }
    
    func patchInput(_ req: Request, _ model: DatabaseModel, _ input: User.Role.Patch) async throws {
        model.patch(input)
    }
    
    func validators(optional: Bool) -> [AsyncValidator] {
        []
    }
}
