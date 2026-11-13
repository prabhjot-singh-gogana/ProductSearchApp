# Product Search App

A native iOS product browser built with SwiftUI. The app loads products from the [DummyJSON Products API](https://dummyjson.com/docs/products), supports searching and pagination, and presents product details in a clean, responsive interface.

## Features

- Browse a paginated product catalogue
- Search products by keyword
- View product details, pricing, ratings, stock, and images
- Loading, empty, and error states
- Pull to refresh
- Unit tests for API request construction, model mapping, pagination, search, and error handling
- UI launch tests

## Architecture

The project separates networking, reusable state, product models, services, view models, and SwiftUI views. API requests use Swift concurrency, while the searchable list is driven by an observable view model with dependency injection for testability.

## Requirements

- Xcode 27 or later
- iOS 27 or later

## Getting Started

1. Clone the repository.
2. Open `ProductSearchApp.xcodeproj` in Xcode.
3. Select an iPhone simulator.
4. Build and run the `ProductSearchApp` scheme.

No API key or additional setup is required.

## Testing

Run the test suite in Xcode with **Product > Test**, or press `Command-U`.

## Data Source

Product data is provided by the public [DummyJSON](https://dummyjson.com/) API.
