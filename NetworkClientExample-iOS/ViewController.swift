//
//  ViewController.swift
//  NetworkClientExample-iOS
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import UIKit

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
    func updateView() {
        print(viewModel.comments)
    }
}

