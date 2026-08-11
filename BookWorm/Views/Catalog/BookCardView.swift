import SwiftUI

struct BookCardView: View {
    let book: Book
    @EnvironmentObject var cartVM: CartViewModel

    @State private var addedToCart = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover
            BookCoverView(book: book, width: .infinity, height: 180)
                .frame(maxWidth: .infinity)
                .frame(height: 180)

            // Details
            VStack(alignment: .leading, spacing: 6) {
                // Category tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(book.categories.prefix(2), id: \.self) { cat in
                            Text(cat)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(AppColors.tag)
                                .cornerRadius(4)
                        }
                    }
                }

                Text(book.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(book.author)
                    .font(.caption)
                    .foregroundColor(AppColors.muted)
                    .lineLimit(1)

                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.accent)
                    Text(String(format: "%.1f", book.rating))
                        .font(.caption2)
                        .foregroundColor(.white)
                    Text("(\(book.reviewCount))")
                        .font(.caption2)
                        .foregroundColor(AppColors.muted)
                    Spacer()
                    Text(book.format.rawValue)
                        .font(.caption2)
                        .foregroundColor(AppColors.muted)
                }

                // Price row
                HStack(alignment: .firstTextBaseline) {
                    Text("₹\(Int(book.price))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accent)

                    if let original = book.originalPrice {
                        Text("₹\(Int(original))")
                            .font(.caption2)
                            .strikethrough()
                            .foregroundColor(AppColors.muted)
                    }

                    if let pct = book.discountPercentage {
                        Text("\(pct)% off")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }

                    Spacer()
                }

                // Delivery
                HStack(spacing: 4) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.green)
                    Text(book.formattedDeliveryDate)
                        .font(.caption2)
                        .foregroundColor(.green)
                }

                // Add to cart button
                Button {
                    cartVM.add(book: book)
                    withAnimation(.spring(response: 0.3)) { addedToCart = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        addedToCart = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: addedToCart ? "checkmark" : "cart.badge.plus")
                            .font(.system(size: 12))
                        Text(addedToCart ? "Added!" : "Add to Cart")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(addedToCart ? Color.green : AppColors.accent)
                    .cornerRadius(8)
                }
                .padding(.top, 4)
            }
            .padding(10)
        }
        .background(AppColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

