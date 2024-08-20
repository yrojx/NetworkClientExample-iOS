//
//  ServiceErrorProtocol.swift
//  NetworkClientExample-iOS
//
//  Created by Yossan Rahmadi on 21/08/24.
//

import Foundation

protocol ServiceErrorProtocol: Error {
    var title: String { get }
    var subtitle: String { get }
    var imageName: String { get }
}
