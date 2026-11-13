//
//  PagedResponse.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

struct PagedResponse<Item: Equatable>: Equatable {
    let items: [Item]
    let total: Int
    let limit: Int
    let skip: Int

    var hasMorePages: Bool {
        skip + items.count < total
    }
}
