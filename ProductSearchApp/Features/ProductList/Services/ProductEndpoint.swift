//
//  ProductEndpoint.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import Foundation

enum ProductEndpoint: APIRequest {
    typealias Response = ProductListResponseDTO

    case list(limit: Int, skip: Int)
    case search(query: String, limit: Int, skip: Int)

    var path: String {
        switch self {
        case .list:
            return "products"
        case .search:
            return "products/search"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .list(let limit, let skip):
            return paginationItems(limit: limit, skip: skip)
        case .search(let query, let limit, let skip):
            return [
                URLQueryItem(name: "q", value: query)
            ] + paginationItems(limit: limit, skip: skip)
        }
    }

    private func paginationItems(limit: Int, skip: Int) -> [URLQueryItem] {
        [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "skip", value: "\(skip)")
        ]
    }
}
