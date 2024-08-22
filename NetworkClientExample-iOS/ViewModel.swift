//
//  ViewModel.swift
//  NetworkClientExample-iOS
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import Foundation

// Can be moved to Modules folder
// Just to make easy to find the file
enum ExampleUIState {
    case loading
    case success
    case error(ExampleServiceError)
}

protocol ViewModelProtocol {
    var action: ViewModelAction? { get set }
    var comments: [Comment] { get }
    
    func viewDidLoad() async
}

protocol ViewModelAction {
    func updateView(uiState: ExampleUIState)
}

final class ViewModel: ViewModelProtocol {
    var action: ViewModelAction?
    
    var comments: [Comment] = []
    private let postId: Int
    private let exampleService: ExampleServiceProtocol
    private var exampleUIState: ExampleUIState = .loading {
        didSet {
            self.action?.updateView(uiState: exampleUIState)
        }
    }
    
    init(postId: Int, exampleService: ExampleServiceProtocol = ExampleService()) {
        self.postId = postId
        self.exampleService = exampleService
    }
    
    func viewDidLoad() async {
        await getComments()
    }
    
    private func getComments() async {
        let result = await exampleService.getComments(with: String(postId))
        
        switch result {
        case .success(let comments):
            self.comments = comments
            self.exampleUIState = .success
        case .failure(let error):
            self.exampleUIState = .error(error)
        }
    }
}
