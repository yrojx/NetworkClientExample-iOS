//
//  ExampleError.swift
//  NetworkClientExample-iOS
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import Foundation

enum ExampleServiceError: ServiceErrorProtocol {
    case network
    case empty
    
    var title: String {
        switch self {
        case .network:
            "Something went wrong"
        case .empty:
            "Comments is empty"
        }
    }
    
    var subtitle: String {
        switch self {
        case .network:
            ""
        case .empty:
            ""
        }
    }
    
    var imageName: String {
        switch self {
        case .network:
            "x.circle"
        case .empty:
            ""
        }
    }
}
