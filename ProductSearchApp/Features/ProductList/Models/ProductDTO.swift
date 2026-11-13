//
//  ProductDTO.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import Foundation

struct ProductListResponseDTO: Decodable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int

    func toPagedResponse() -> PagedResponse<Product> {
        PagedResponse(
            items: products.map { $0.toDomain() },
            total: total,
            limit: limit,
            skip: skip
        )
    }
}
struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Decimal
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let brand: String?
    let thumbnail: String?

    func toDomain() -> Product {
        Product(
            id: id,
            title: title,
            brand: brand ?? "Unknown brand",
            category: category,
            description: description,
            price: price,
            discountPercentage: discountPercentage,
            rating: rating,
            stock: stock,
            thumbnailURL: thumbnail.flatMap(URL.init(string:))
        )
    }
}

