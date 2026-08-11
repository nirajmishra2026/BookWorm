import Foundation
import Combine

class CatalogViewModel: ObservableObject {
    @Published var allBooks: [Book] = []
    @Published var selectedCategory: String = "All"
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .relevance

    enum SortOption: String, CaseIterable {
        case relevance   = "Relevance"
        case priceLow    = "Price: Low to High"
        case priceHigh   = "Price: High to Low"
        case rating      = "Top Rated"
        case newest      = "Newest"
    }

    init() {
        allBooks = SampleData.books
    }

    var filteredBooks: [Book] {
        var books = allBooks

        if selectedCategory != "All" {
            books = books.filter { $0.categories.contains(selectedCategory) }
        }

        if !searchText.isEmpty {
            books = books.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText) ||
                $0.categories.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }

        switch sortOption {
        case .relevance:  break
        case .priceLow:   books.sort { $0.price < $1.price }
        case .priceHigh:  books.sort { $0.price > $1.price }
        case .rating:     books.sort { $0.rating > $1.rating }
        case .newest:     books.sort { $0.publishDate > $1.publishDate }
        }

        return books
    }

    var recommendedBooks: [Book] { allBooks.filter { $0.isRecommended } }
    var bestsellers: [Book]      { allBooks.filter { $0.isBestseller } }
    var newLaunches: [Book]      { allBooks.filter { $0.isNewLaunch } }

    func recommendations(for orderHistory: [Order]) -> [Book] {
        let purchasedCategories = Set(
            orderHistory.flatMap { $0.items }.flatMap { item in
                allBooks.first(where: { $0.id == item.bookID })?.categories ?? []
            }
        )
        let purchasedIDs = Set(orderHistory.flatMap { $0.items }.map { $0.bookID })

        let recs = allBooks.filter { book in
            !purchasedIDs.contains(book.id) &&
            book.categories.contains(where: { purchasedCategories.contains($0) })
        }
        return recs.isEmpty ? Array(allBooks.prefix(6)) : Array(recs.prefix(6))
    }
}
