//
//  SearchableListViewModelProtocol.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import Foundation

@MainActor
protocol SearchableListViewModelProtocol: AnyObject {
    associatedtype Item: Identifiable & Equatable

    var items: [Item] { get }
    var query: String { get set }
    var state: ViewState { get }
    var isLoadingNextPage: Bool { get }
    var canLoadMore: Bool { get }
    var errorMessage: String? { get }

    func loadInitial() async
    func refresh() async
    func search() async
    func searchAfterDelay(nanoseconds: UInt64) async
    func loadNextPageIfNeeded(currentItem: Item?) async
}
