//
//  ExampleEndpoint.swift
//  NetworkClientExample-iOS
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import Foundation

enum ExampleEndpoint: Endpoint {
    case getCommentsWith(postId: String)
    
    var host: String {
        "jsonplaceholder.typicode.com"
    }
    
    var path: String {
        switch self {
        case .getCommentsWith: "/comments"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCommentsWith: .get
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .getCommentsWith(let postId):
            [
                URLQueryItem(name: "postId", value: postId)
            ]
        }
    }
}
