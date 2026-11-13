//
//  ProductService.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import Foundation

struct ProductService: SearchableListServiceProtocol {
    private let fetchProducts: (ProductEndpoint) async throws -> ProductListResponseDTO

    init(apiClient: APIClient = APIClient(baseURL: URL(string: "https://dummyjson.com")!)) {
        fetchProducts = { endpoint in
            try await apiClient.send(endpoint)
        }
    }

    init(fetchProducts: @escaping (ProductEndpoint) async throws -> ProductListResponseDTO) {
        self.fetchProducts = fetchProducts
    }

    func fetchItems(query: String, limit: Int, skip: Int) async throws -> PagedResponse<Product> {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let endpoint: ProductEndpoint = trimmedQuery.isEmpty
            ? .list(limit: limit, skip: skip)
            : .search(query: trimmedQuery, limit: limit, skip: skip)

        let response = try await fetchProducts(endpoint)
        return response.toPagedResponse()
    }
}
