//
//  ProductSearchAppTests.swift
//  ProductSearchAppTests
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import XCTest
@testable import ProductSearchApp

final class ProductSearchAppTests: XCTestCase {
    func testProductEndpointBuildsListRequest() {
        let endpoint = ProductEndpoint.list(limit: 20, skip: 40)

        XCTAssertEqual(endpoint.path, "products")
        XCTAssertEqual(endpoint.queryItems, [
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "skip", value: "40")
        ])
    }

    func testProductEndpointBuildsSearchRequest() {
        let endpoint = ProductEndpoint.search(query: "phone", limit: 10, skip: 20)

        XCTAssertEqual(endpoint.path, "products/search")
        XCTAssertEqual(endpoint.queryItems, [
            URLQueryItem(name: "q", value: "phone"),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "skip", value: "20")
        ])
    }

    func testProductDTOMapsToDomainModel() throws {
        let data = """
        {
          "products": [
            {
              "id": 1,
              "title": "Phone",
              "description": "A useful phone",
              "category": "smartphones",
              "price": 799,
              "discountPercentage": 7.5,
              "rating": 4.6,
              "stock": 12,
              "brand": "Example",
              "thumbnail": "https://example.com/phone.jpg"
            }
          ],
          "total": 1,
          "skip": 0,
          "limit": 20
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(ProductListResponseDTO.self, from: data)
        let page = response.toPagedResponse()

        XCTAssertEqual(page.total, 1)
        XCTAssertEqual(page.items.first?.title, "Phone")
        XCTAssertEqual(page.items.first?.brand, "Example")
        XCTAssertEqual(page.items.first?.thumbnailURL, URL(string: "https://example.com/phone.jpg"))
    }

    @MainActor
    func testViewModelLoadsInitialProducts() async {
        let service = MockProductService(pages: [
            PagedResponse(items: [.fixture(id: 1), .fixture(id: 2)], total: 2, limit: 20, skip: 0)
        ])
        let viewModel = SearchableListViewModel(service: service)

        await viewModel.loadInitial()

        XCTAssertEqual(viewModel.items.map(\.id), [1, 2])
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertFalse(viewModel.canLoadMore)
    }

    @MainActor
    func testViewModelSearchResetsItemsAndUsesQuery() async {
        let service = MockProductService(pages: [
            PagedResponse(items: [.fixture(id: 1)], total: 5, limit: 20, skip: 0),
            PagedResponse(items: [.fixture(id: 10, title: "Laptop")], total: 1, limit: 20, skip: 0)
        ])
        let viewModel = SearchableListViewModel(service: service)

        await viewModel.loadInitial()
        viewModel.query = " laptop "
        await viewModel.search()

        XCTAssertEqual(viewModel.items, [.fixture(id: 10, title: "Laptop")])
        XCTAssertEqual(service.requests.map(\.query), ["", "laptop"])
    }

    @MainActor
    func testViewModelLoadsNextPageNearEndOfList() async {
        let service = MockProductService(pages: [
            PagedResponse(items: [.fixture(id: 1), .fixture(id: 2)], total: 3, limit: 2, skip: 0),
            PagedResponse(items: [.fixture(id: 3)], total: 3, limit: 2, skip: 2)
        ])
        let viewModel = SearchableListViewModel(service: service, pageSize: 2)

        await viewModel.loadInitial()
        await viewModel.loadNextPageIfNeeded(currentItem: .fixture(id: 2))

        XCTAssertEqual(viewModel.items.map(\.id), [1, 2, 3])
        XCTAssertFalse(viewModel.canLoadMore)
        XCTAssertEqual(service.requests.map(\.skip), [0, 2])
    }

    @MainActor
    func testViewModelShowsErrorStateWhenInitialLoadFails() async {
        let service = MockProductService(error: NetworkError.invalidResponse)
        let viewModel = SearchableListViewModel(service: service)

        await viewModel.loadInitial()

        XCTAssertEqual(viewModel.items, [])
        XCTAssertEqual(viewModel.state, .error("The server returned an invalid response."))
    }
}

private final class MockProductService: SearchableListServiceProtocol {
    struct Request: Equatable {
        let query: String
        let limit: Int
        let skip: Int
    }

    private var pages: [PagedResponse<Product>]
    private let error: Error?
    private(set) var requests: [Request] = []

    init(pages: [PagedResponse<Product>] = [], error: Error? = nil) {
        self.pages = pages
        self.error = error
    }

    func fetchItems(query: String, limit: Int, skip: Int) async throws -> PagedResponse<Product> {
        requests.append(Request(query: query, limit: limit, skip: skip))

        if let error {
            throw error
        }

        return pages.isEmpty
            ? PagedResponse(items: [], total: 0, limit: limit, skip: skip)
            : pages.removeFirst()
    }
}

private extension Product {
    static func fixture(id: Int, title: String? = nil) -> Product {
        Product(
            id: id,
            title: title ?? "Product \(id)",
            brand: "Brand",
            category: "category",
            description: "Description",
            price: Decimal(id * 10),
            discountPercentage: 0,
            rating: 4,
            stock: 10,
            thumbnailURL: nil
        )
    }
}
