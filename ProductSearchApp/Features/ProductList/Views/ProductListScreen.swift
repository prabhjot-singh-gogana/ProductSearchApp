//
//  ProductListScreen.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import SwiftUI

struct ProductListScreen: View {
    @State private var viewModel = SearchableListViewModel(service: ProductService())

    var body: some View {
        SearchableListView(
            title: "Products",
            searchPrompt: "Search products",
            viewModel: viewModel
        ) { product in
            ProductRowView(product: product)
        } detailContent: { product in
            ProductDetailView(product: product)
        }
    }
}

#Preview {
    ProductListScreen()
}
