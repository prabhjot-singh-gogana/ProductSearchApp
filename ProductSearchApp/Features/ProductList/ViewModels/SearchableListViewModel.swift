//
//  SearchableListViewModel.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class SearchableListViewModel<Service: SearchableListServiceProtocol>: SearchableListViewModelProtocol {
    private let service: Service
    private let pageSize: Int
    private var totalCount = 0
    private var loadedQuery = ""
    private var hasLoadedInitialPage = false
    private var isLoadingPage = false

    private(set) var items: [Service.Item] = []
    var query = ""
    private(set) var state: ViewState = .idle
    private(set) var isLoadingNextPage = false
    private(set) var errorMessage: String?

    var canLoadMore: Bool {
        items.count < totalCount || !hasLoadedInitialPage
    }

    init(service: Service, pageSize: Int = 20) {
        self.service = service
        self.pageSize = pageSize
    }

    func loadInitial() async {
        guard !hasLoadedInitialPage else { return }
        await loadPage(reset: true, query: query)
    }

    func refresh() async {
        await loadPage(reset: true, query: query)
    }

    func search() async {
        let normalizedQuery = normalize(query)
        guard normalizedQuery != loadedQuery || !hasLoadedInitialPage else { return }
        await loadPage(reset: true, query: normalizedQuery)
    }

    func searchAfterDelay(nanoseconds: UInt64 = 350_000_000) async {
        do {
            try await Task.sleep(nanoseconds: nanoseconds)
            await search()
        } catch {
            return
        }
    }

    func loadNextPageIfNeeded(currentItem: Service.Item?) async {
        guard shouldLoadNextPage(currentItem: currentItem) else { return }
        await loadPage(reset: false, query: loadedQuery)
    }

    private func shouldLoadNextPage(currentItem: Service.Item?) -> Bool {
        guard hasLoadedInitialPage, canLoadMore, !isLoadingPage else { return false }
        guard let currentItem else { return true }
        return items.suffix(5).contains(currentItem)
    }

    private func loadPage(reset: Bool, query: String) async {
        guard !isLoadingPage else { return }

        isLoadingPage = true
        errorMessage = nil

        if reset {
            state = .loading
            isLoadingNextPage = false
        } else {
            isLoadingNextPage = true
        }

        do {
            let skip = reset ? 0 : items.count
            let page = try await service.fetchItems(query: query, limit: pageSize, skip: skip)
            apply(page: page, reset: reset, query: query)
        } catch {
            apply(error: error, reset: reset)
        }

        isLoadingNextPage = false
        isLoadingPage = false
    }

    private func apply(page: PagedResponse<Service.Item>, reset: Bool, query: String) {
        loadedQuery = normalize(query)
        totalCount = page.total
        hasLoadedInitialPage = true

        if reset {
            items = page.items
        } else {
            let existingIDs = Set(items.map(\.id))
            items.append(contentsOf: page.items.filter { !existingIDs.contains($0.id) })
        }

        state = items.isEmpty ? .empty : .loaded
    }

    private func apply(error: Error, reset: Bool) {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        errorMessage = message

        if reset {
            items = []
            totalCount = 0
            hasLoadedInitialPage = true
            state = .error(message)
        } else {
            state = items.isEmpty ? .error(message) : .loaded
        }
    }

    private func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
