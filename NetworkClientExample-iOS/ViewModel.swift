//
//  ViewModel.swift
//  NetworkClientExample-iOS
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import Foundation

protocol ViewModelProtocol {
    var action: ViewModelAction? { get set }
    var comments: [Comment] { get }
    
    func viewDidLoad() async
}

protocol ViewModelAction {
    func updateView()
}

final class ViewModel: ViewModelProtocol {
    var action: ViewModelAction?
    
    var comments: [Comment] = []
    private let postId: Int
    private let exampleService: ExampleServiceProtocol
    
    init(postId: Int, exampleService: ExampleServiceProtocol = ExampleService()) {
        self.postId = postId
        self.exampleService = exampleService
    }
    
    func viewDidLoad() async {
        await getComments()
        action?.updateView()
    }
    
    private func getComments() async {
        let result = await exampleService.getComments(with: String(postId))
        
        switch result {
        case .success(let comments):
            self.comments = comments
        case .failure(let error):
            print(error)
        }
    }
}
