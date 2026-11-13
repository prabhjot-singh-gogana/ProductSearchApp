//
//  APIClient.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import Foundation

protocol APIClientProtocol {
    func send<Request: APIRequest>(_ request: Request) async throws -> Request.Response
}

struct APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: NetworkSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        session: NetworkSession = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    func send<Request: APIRequest>(_ request: Request) async throws -> Request.Response {
        let urlRequest = try makeURLRequest(for: request)

        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.httpStatus(httpResponse.statusCode)
            }

            do {
                return try decoder.decode(Request.Response.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error)
        }
    }

    private func makeURLRequest<Request: APIRequest>(for request: Request) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        let cleanBasePath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let cleanRequestPath = request.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.path = "/" + [cleanBasePath, cleanRequestPath]
            .filter { !$0.isEmpty }
            .joined(separator: "/")
        components.queryItems = request.queryItems.isEmpty ? nil : request.queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.timeoutInterval = 30
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        return urlRequest
    }
}
