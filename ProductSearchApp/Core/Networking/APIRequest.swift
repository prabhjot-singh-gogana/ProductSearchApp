//
//  APIRequest.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import Foundation

protocol APIRequest {
    associatedtype Response: Decodable

    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension APIRequest {
    var queryItems: [URLQueryItem] {
        []
    }
}
