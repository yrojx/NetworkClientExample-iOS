//
//  NetworkError.swift
//  NetworkClientExample-iOS
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import Foundation

enum NetworkError: Error, Equatable {
    case badURL
    case invalidResponse
    case notFound
    case internalServerError
    case unsupportedContentType
    case decodingFailed(Error)
    case requestFailed(Error)
    case unknownError(statusCode: Int)
    
    // For testing purpose
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.badURL, .badURL),
             (.invalidResponse, .invalidResponse),
             (.notFound, .notFound),
             (.internalServerError, .internalServerError),
             (.unsupportedContentType, .unsupportedContentType):
            return true
        case (.requestFailed(let lhsError), .requestFailed(let rhsError)):
            return (lhsError as NSError).domain == (rhsError as NSError).domain &&
                   (lhsError as NSError).code == (rhsError as NSError).code
        case (.unknownError(let lhsCode), .unknownError(let rhsCode)):
            return lhsCode == rhsCode
        case (.decodingFailed(let lhsError), .decodingFailed(let rhsError)):
            return (lhsError as NSError).domain == (rhsError as NSError).domain &&
                   (lhsError as NSError).code == (rhsError as NSError).code
        default:
            return false
        }
    }
}
