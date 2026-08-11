import SwiftUI

struct CatalogView: View {
    @EnvironmentObject var catalogVM: CatalogViewModel
    @EnvironmentObject var cartVM:    CartViewModel

    @State private var selectedBook: Book? = nil
    @State private var showSortSheet = false

    // iPad sidebar detection
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if sizeClass == .regular {
                    // iPad: side-by-side category list + grid
                    HStack(spacing: 0) {
                        categoryList
                            .frame(width: 180)
                            .background(AppColors.surface)
                        Divider().background(AppColors.border)
                        bookGrid
                    }
                } else {
                    // iPhone: stacked with horizontal category scroll
                    VStack(spacing: 0) {
                        categoryScrollBar
                        bookGrid
                    }
                }
            }
            .navigationTitle("Catalog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSortSheet = true
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                            .labelStyle(.iconOnly)
                            .foregroundColor(.white)
                    }
                }
            }
            .searchable(text: $catalogVM.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search books or authors")
            .confirmationDialog("Sort By", isPresented: $showSortSheet, titleVisibility: .visible) {
                ForEach(CatalogViewModel.SortOption.allCases, id: \.self) { option in
                    Button(option.rawValue) {
                        catalogVM.sortOption = option
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .navigationDestination(item: $selectedBook) { book in
                BookDetailView(book: book)
                    .environmentObject(cartVM)
                    .environmentObject(catalogVM)
            }
        }
    }

    // MARK: - Category list (iPad sidebar)
    private var categoryList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 2) {
                ForEach(allCategories, id: \.self) { category in
                    CategoryRow(
                        title: category,
                        isSelected: catalogVM.selectedCategory == category,
                        count: category == "All" ? catalogVM.allBooks.count
                             : catalogVM.allBooks.filter { $0.categories.contains(category) }.count
                    )
                    .onTapGesture {
                        catalogVM.selectedCategory = category
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Category horizontal scroll (iPhone)
    private var categoryScrollBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(allCategories, id: \.self) { category in
                    Text(category)
                        .font(.caption)
                        .fontWeight(catalogVM.selectedCategory == category ? .bold : .regular)
                        .foregroundColor(catalogVM.selectedCategory == category ? .black : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            catalogVM.selectedCategory == category
                            ? AppColors.accent
                            : AppColors.surface
                        )
                        .cornerRadius(20)
                        .onTapGesture {
                            catalogVM.selectedCategory = category
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(AppColors.surface)
    }

    // MARK: - Book grid
    private var bookGrid: some View {
        let books = catalogVM.filteredBooks
        let cols = sizeClass == .regular
            ? [GridItem(.adaptive(minimum: 180, maximum: 220), spacing: 16)]
            : [GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 14)]

        return ScrollView(showsIndicators: false) {
            if books.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: cols, spacing: 16) {
                    ForEach(books) { book in
                        BookCardView(book: book)
                            .onTapGesture { selectedBook = book }
                            .environmentObject(cartVM)
                    }
                }
                .padding(16)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(AppColors.muted)
            Text("No books found")
                .font(.headline)
                .foregroundColor(.white)
            Text("Try adjusting your search or category filter.")
                .font(.caption)
                .foregroundColor(AppColors.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

// MARK: - Category Row (iPad)
struct CategoryRow: View {
    let title: String
    let isSelected: Bool
    let count: Int

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(isSelected ? AppColors.accent : .white)
                .fontWeight(isSelected ? .semibold : .regular)
            Spacer()
            Text("\(count)")
                .font(.caption2)
                .foregroundColor(AppColors.muted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isSelected ? AppColors.accent.opacity(0.12) : Color.clear)
        .contentShape(Rectangle())
    }
}
