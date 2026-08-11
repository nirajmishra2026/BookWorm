import SwiftUI

struct HomeView: View {
    @EnvironmentObject var catalogVM: CatalogViewModel
    @EnvironmentObject var cartVM:    CartViewModel
    @Binding var selectedTab: ContentView.Tab

    @State private var selectedBook: Book? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // Hero banner
                        heroBanner
                            .padding(.horizontal, 16)

                        // Recommended
                        bookSection(
                            title: "Recommended for You",
                            systemImage: "star.fill",
                            books: catalogVM.recommendedBooks
                        )

                        // Bestsellers
                        bookSection(
                            title: "Bestsellers",
                            systemImage: "flame.fill",
                            books: catalogVM.bestsellers
                        )

                        // New Launches
                        bookSection(
                            title: "New Launches",
                            systemImage: "sparkles",
                            books: catalogVM.newLaunches
                        )

                        Spacer(minLength: 20)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("BookWorm")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedTab = .cart
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                                .foregroundColor(.white)
                            if cartVM.itemCount > 0 {
                                Text("\(cartVM.itemCount)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(3)
                                    .background(AppColors.accent)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedBook) { book in
                BookDetailView(book: book)
                    .environmentObject(cartVM)
                    .environmentObject(catalogVM)
            }
        }
    }

    // MARK: - Hero Banner
    private var heroBanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.25, green: 0.15, blue: 0.55),
                                 Color(red: 0.08, green: 0.08, blue: 0.22)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 140)

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("🎁 Welcome Offer")
                        .font(.caption)
                        .foregroundColor(AppColors.accent)
                        .fontWeight(.semibold)
                    Text("Get 50 gift points\non your first order!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Use points to save on checkout")
                        .font(.caption)
                        .foregroundColor(AppColors.muted)
                }
                Spacer()
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 56))
                    .foregroundColor(AppColors.accent.opacity(0.6))
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Book Section
    private func bookSection(title: String, systemImage: String, books: [Book]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(AppColors.accent)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button("See All") {
                    selectedTab = .catalog
                }
                .font(.caption)
                .foregroundColor(AppColors.accent)
                .padding(.trailing, 16)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(books) { book in
                        HomeBookCard(book: book)
                            .onTapGesture { selectedBook = book }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Compact home book card
struct HomeBookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover
            BookCoverView(book: book, width: 120, height: 160)

            VStack(alignment: .leading, spacing: 3) {
                Text(book.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .frame(width: 120, alignment: .leading)

                Text(book.author)
                    .font(.caption2)
                    .foregroundColor(AppColors.muted)
                    .lineLimit(1)

                Text("₹\(Int(book.price))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.accent)
            }
        }
        .frame(width: 120)
    }
}

// MARK: - Reusable book cover view
struct BookCoverView: View {
    let book: Book
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [book.coverColor.color, book.coverColor.secondaryColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: width, height: height)
            .cornerRadius(8)

            // Spine effect
            Rectangle()
                .fill(book.coverColor.secondaryColor.opacity(0.5))
                .frame(width: 6, height: height)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(8)

            VStack(spacing: 4) {
                Text(book.title)
                    .font(.system(size: min(12, 120 / CGFloat(book.title.count) * 6)))
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .lineLimit(3)

                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.horizontal, 12)

                Text(book.author)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .lineLimit(2)
            }
        }
        .frame(width: width, height: height)
        .shadow(color: book.coverColor.color.opacity(0.4), radius: 6, x: 0, y: 4)
    }
}
