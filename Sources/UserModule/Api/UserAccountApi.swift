//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2022. 02. 24..
//

public struct UserAccountApi {

    let repository: UserAccountRepository
    
    init(_ repository: UserAccountRepository) {
        self.repository = repository
    }
}

public extension UserAccountApi {

    func list() async throws -> [User.Account.List] {
        try await repository.list().transform(to: [User.Account.List].self)
    }
    
    func list(_ id: UUID) async throws -> User.Account.List? {
        try await repository.get(id)?.transform(to: User.Account.List.self)
    }
    
    func list(_ ids: [UUID]) async throws -> [User.Account.List] {
        try await repository.get(ids).transform(to: [User.Account.List].self)
    }
    
    func get(_ id: UUID) async throws -> User.Account.Detail? {
        try await repository.get(id)?.transform(to: User.Account.Detail.self)
    }

    func get(_ ids: [UUID]) async throws -> [User.Account.Detail] {
        try await repository.get(ids).transform(to: [User.Account.Detail].self)
    }

    func optionList() async throws -> [OptionContext] {
        try await list().map { .init(key: $0.id.string, label: $0.email) }
    }
}
