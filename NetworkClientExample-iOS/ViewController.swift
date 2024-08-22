//
//  ViewController.swift
//  NetworkClientExample-iOS
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import UIKit

// Can be moved to Modules folder
// Just to make easy to find the file
final class ViewController: UIViewController {
    
    private var viewModel: ViewModelProtocol
    
    init(viewModel: ViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.action = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await viewModel.viewDidLoad()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewController: ViewModelAction {
    func updateView(uiState: ExampleUIState) {
        print(uiState) // just to show if it works
        switch uiState {
        case .loading:
            // show loading
            break
        case .success:
            // show content
            break
        case .error(let exampleServiceError):
            // show error
            // can create generic ErrorView that showing info in the ServiceErrorProtocol
            // self.errorView.updateView(with: exampleServiceError)
            break
        }
    }
}

