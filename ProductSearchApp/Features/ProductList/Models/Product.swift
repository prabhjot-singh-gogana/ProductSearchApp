//
//  Product.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import Foundation

struct Product: Identifiable, Equatable, Sendable {
    let id: Int
    let title: String
    let brand: String
    let category: String
    let description: String
    let price: Decimal
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let thumbnailURL: URL?

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSDecimalNumber) ?? "$\(price)"
    }

    var subtitle: String {
        [brand, category.capitalized]
            .filter { !$0.isEmpty }
            .joined(separator: " • ")
    }
}

extension Product {
    static let preview = Product(
        id: 1,
        title: "iPhone 15 Pro",
        brand: "Apple",
        category: "smartphones",
        description: "A titanium smartphone with a fast chip, excellent camera system, and polished everyday performance.",
        price: Decimal(999),
        discountPercentage: 8.5,
        rating: 4.7,
        stock: 42,
        thumbnailURL: URL(string: "https://cdn.dummyjson.com/product-images/1/thumbnail.jpg")
    )
}
