//
//  ProductDetailView.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: product.thumbnailURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 220)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 8) {
                    Text(product.title)
                        .font(.title2.bold())

                    Text(product.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    MetricView(title: "Price", value: product.formattedPrice)
                    MetricView(title: "Rating", value: product.rating.formatted(.number.precision(.fractionLength(1))))
                    MetricView(title: "Stock", value: "\(product.stock)")
                }

                Text(product.description)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .padding()
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MetricView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: .preview)
    }
}
