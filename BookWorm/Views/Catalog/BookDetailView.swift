import SwiftUI

struct BookDetailView: View {
    let book: Book
    @EnvironmentObject var cartVM:    CartViewModel
    @EnvironmentObject var catalogVM: CatalogViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFormat: BookFormat
    @State private var quantity = 1
    @State private var addedToCart = false
    @State private var showFullDescription = false

    init(book: Book) {
        self.book = book
        _selectedFormat = State(initialValue: book.format)
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Cover hero
                    coverHero

                    // Detail content
                    VStack(alignment: .leading, spacing: 20) {
                        titleSection
                        Divider().background(AppColors.border)
                        formatSelector
                        Divider().background(AppColors.border)
                        priceAndDelivery
                        Divider().background(AppColors.border)
                        descriptionSection
                        Divider().background(AppColors.border)
                        bookInfo
                        relatedBooks
                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }
            }

            // Sticky add-to-cart bar
            VStack {
                Spacer()
                addToCartBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
    }

    // MARK: - Cover hero
    private var coverHero: some View {
        ZStack {
            LinearGradient(
                colors: [book.coverColor.secondaryColor,
                         AppColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)

            BookCoverView(book: book, width: 140, height: 200)
                .padding(.top, 20)
        }
        .frame(height: 280)
    }

    // MARK: - Title section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Badges
            HStack(spacing: 8) {
                if book.isBestseller {
                    badgeView("Bestseller", color: .orange)
                }
                if book.isNewLaunch {
                    badgeView("New Launch", color: .green)
                }
                if book.isRecommended {
                    badgeView("Recommended", color: .blue)
                }
            }

            Text(book.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("by \(book.author)")
                .font(.subheadline)
                .foregroundColor(AppColors.muted)

            // Rating row
            HStack(spacing: 6) {
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < Int(book.rating.rounded()) ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.accent)
                    }
                }
                Text(String(format: "%.1f", book.rating))
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("(\(book.reviewCount) reviews)")
                    .font(.caption)
                    .foregroundColor(AppColors.muted)
            }

            // Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(book.categories, id: \.self) { cat in
                        Text(cat)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppColors.tag)
                            .cornerRadius(6)
                    }
                }
            }
        }
    }

    // MARK: - Format selector
    private var formatSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Format")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            HStack(spacing: 12) {
                ForEach(BookFormat.allCases, id: \.self) { fmt in
                    Text(fmt.rawValue)
                        .font(.caption)
                        .fontWeight(selectedFormat == fmt ? .bold : .regular)
                        .foregroundColor(selectedFormat == fmt ? .black : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedFormat == fmt ? AppColors.accent : AppColors.surface2)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedFormat == fmt ? Color.clear : AppColors.border, lineWidth: 1)
                        )
                        .onTapGesture { selectedFormat = fmt }
                }
            }
        }
    }

    // MARK: - Price & Delivery
    private var priceAndDelivery: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("₹\(Int(book.price))")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.accent)

                if let original = book.originalPrice {
                    Text("₹\(Int(original))")
                        .font(.body)
                        .strikethrough()
                        .foregroundColor(AppColors.muted)
                    if let pct = book.discountPercentage {
                        Text("\(pct)% off")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "shippingbox.fill").foregroundColor(.green)
                Text("Free delivery by **\(book.formattedDeliveryDate)**")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }

            // Quantity stepper
            HStack(spacing: 16) {
                Text("Qty:")
                    .font(.subheadline)
                    .foregroundColor(AppColors.muted)

                HStack(spacing: 0) {
                    Button {
                        if quantity > 1 { quantity -= 1 }
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 36, height: 36)
                            .foregroundColor(.white)
                            .background(AppColors.surface2)
                    }
                    Text("\(quantity)")
                        .frame(width: 40, height: 36)
                        .foregroundColor(.white)
                        .background(AppColors.surface)
                    Button {
                        quantity += 1
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 36, height: 36)
                            .foregroundColor(.white)
                            .background(AppColors.surface2)
                    }
                }
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.border, lineWidth: 1))
            }
        }
    }

    // MARK: - Description
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About this book")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text(book.description)
                .font(.body)
                .foregroundColor(Color(white: 0.80))
                .lineLimit(showFullDescription ? nil : 4)

            Button(showFullDescription ? "Show less" : "Read more") {
                showFullDescription.toggle()
            }
            .font(.caption)
            .foregroundColor(AppColors.accent)
        }
    }

    // MARK: - Book info
    private var bookInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Book Details")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            infoRow("Pages",     book.pageCount.description)
            infoRow("Publisher", book.publisher)
            infoRow("ISBN",      book.isbn)
        }
    }

    // MARK: - Related Books
    @ViewBuilder
    private var relatedBooks: some View {
        let related = catalogVM.allBooks.filter { other in
            other.id != book.id &&
            other.categories.contains(where: { book.categories.contains($0) })
        }.prefix(6)

        if !related.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("You may also like")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(Array(related)) { rel in
                            NavigationLink {
                                BookDetailView(book: rel)
                                    .environmentObject(cartVM)
                                    .environmentObject(catalogVM)
                            } label: {
                                HomeBookCard(book: rel)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sticky bar
    private var addToCartBar: some View {
        HStack(spacing: 12) {
            Button {
                for _ in 0..<quantity { cartVM.add(book: book, format: selectedFormat) }
                withAnimation { addedToCart = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { addedToCart = false }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: addedToCart ? "checkmark.circle.fill" : "cart.badge.plus")
                    Text(addedToCart ? "Added to Cart!" : "Add to Cart")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(addedToCart ? Color.green : AppColors.accent)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            AppColors.background
                .shadow(color: .black.opacity(0.5), radius: 10, y: -5)
        )
    }

    // MARK: - Helpers
    private func badgeView(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.7))
            .cornerRadius(5)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.muted)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}
