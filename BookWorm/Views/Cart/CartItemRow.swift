import SwiftUI

struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cartVM: CartViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Cover thumbnail
            BookCoverView(book: item.book, width: 64, height: 88)

            // Details
            VStack(alignment: .leading, spacing: 5) {
                Text(item.book.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(item.book.author)
                    .font(.caption)
                    .foregroundColor(AppColors.muted)

                Text(item.format.rawValue)
                    .font(.caption2)
                    .foregroundColor(AppColors.muted)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.surface2)
                    .cornerRadius(4)

                HStack(spacing: 4) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.green)
                    Text(item.book.formattedDeliveryDate)
                        .font(.caption2)
                        .foregroundColor(.green)
                }

                HStack(spacing: 12) {
                    Text("₹\(String(format: "%.0f", item.book.price))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accent)

                    Spacer()

                    // Quantity control
                    HStack(spacing: 0) {
                        Button {
                            cartVM.decreaseQuantity(of: item)
                        } label: {
                            Image(systemName: item.quantity == 1 ? "trash" : "minus")
                                .font(.system(size: 11))
                                .frame(width: 28, height: 28)
                                .foregroundColor(item.quantity == 1 ? .red : .white)
                                .background(AppColors.surface2)
                        }

                        Text("\(item.quantity)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 32, height: 28)
                            .background(AppColors.surface)

                        Button {
                            cartVM.increaseQuantity(of: item)
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 11))
                                .frame(width: 28, height: 28)
                                .foregroundColor(.white)
                                .background(AppColors.surface2)
                        }
                    }
                    .cornerRadius(7)
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(AppColors.border, lineWidth: 1))
                }
            }

            // Remove button
            Button {
                cartVM.remove(item: item)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.muted)
                    .padding(6)
                    .background(AppColors.surface2)
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(AppColors.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 1))
    }
}
