//
//  SearchableListView.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

import Observation
import SwiftUI

struct SearchableListView<
    ViewModel: SearchableListViewModelProtocol & Observable,
    RowContent: View,
    DetailContent: View
>: View {
    let title: String
    let searchPrompt: String
    @Bindable var viewModel: ViewModel
    let rowContent: (ViewModel.Item) -> RowContent
    let detailContent: (ViewModel.Item) -> DetailContent

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle where viewModel.items.isEmpty,
                     .loading where viewModel.items.isEmpty:
                    loadingView
                case .empty:
                    ContentUnavailableView(
                        viewModel.query.isEmpty ? "No products" : "No results",
                        systemImage: "magnifyingglass",
                        description: Text(viewModel.query.isEmpty ? "Pull to refresh and try again." : "Try another search term.")
                    )
                case .error(let message) where viewModel.items.isEmpty:
                    ContentUnavailableView {
                        Label("Could not load products", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Retry") {
                            Task { await viewModel.refresh() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                default:
                    listView
                }
            }
            .navigationTitle(title)
            .searchable(text: $viewModel.query, prompt: searchPrompt)
            .textInputAutocapitalization(.never)
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadInitial()
            }
            .task(id: viewModel.query) {
                await viewModel.searchAfterDelay(nanoseconds: 350_000_000)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading products")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var listView: some View {
        List {
            ForEach(viewModel.items) { item in
                NavigationLink {
                    detailContent(item)
                } label: {
                    rowContent(item)
                }
                .task {
                    await viewModel.loadNextPageIfNeeded(currentItem: item)
                }
            }

            if viewModel.isLoadingNextPage {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }

            if let message = viewModel.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}
