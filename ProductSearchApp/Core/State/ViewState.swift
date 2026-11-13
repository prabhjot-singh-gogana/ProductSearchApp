//
//  ViewState.swift
//  ProductSearchApp
//
//  Created by Prabhjot Singh on 21/9/2026.
//

enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}
