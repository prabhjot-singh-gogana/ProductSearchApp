//
//  NetworkError.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpStatus(let code):
            return "The server returned status code \(code)."
        case .decodingFailed:
            return "The app could not read the server response."
        case .transport(let error):
            return error.localizedDescription
        }
    }
}
