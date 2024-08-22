//
//  ExampleService.swift
//  NetworkClientExample-iOS
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import Foundation

protocol ExampleServiceProtocol {
    func getComments(with postId: String) async -> Result<[Comment], ExampleServiceError>
}

final class ExampleService: ExampleServiceProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient(urlSessionConfiguration: .default)) {
        self.networkClient = networkClient
    }
    
    func getComments(with postId: String) async -> Result<[Comment], ExampleServiceError> {
        do {
            let response: [Comment] = try await networkClient.request(target: ExampleEndpoint.getCommentsWith(postId: postId))
            
            return !response.isEmpty ? .success(response) : .failure(.empty)
        } catch {
            return .failure(.network)
        }
    }
}
