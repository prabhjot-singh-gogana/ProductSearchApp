//
//  SearchableListServiceProtocol.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

protocol SearchableListServiceProtocol {
    associatedtype Item: Identifiable & Equatable

    func fetchItems(query: String, limit: Int, skip: Int) async throws -> PagedResponse<Item>
}
