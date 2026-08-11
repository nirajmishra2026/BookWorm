import SwiftUI

struct OrderHistoryView: View {
    @EnvironmentObject var orderVM:   OrderViewModel
    @EnvironmentObject var cartVM:    CartViewModel
    @EnvironmentObject var catalogVM: CatalogViewModel

    @State private var selectedOrder: Order? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if orderVM.orders.isEmpty {
                    emptyState
                } else {
                    orderList
                }
            }
            .navigationTitle("Order History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .navigationDestination(item: $selectedOrder) { order in
                OrderDetailView(order: order)
                    .environmentObject(orderVM)
                    .environmentObject(cartVM)
                    .environmentObject(catalogVM)
            }
        }
    }

    private var orderList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                // Recommendations based on order history
                if !orderVM.orders.isEmpty {
                    recommendationsSection
                }

                ForEach(orderVM.orders) { order in
                    OrderCard(order: order, onBuyAgain: {
                        buyAgain(order: order)
                    })
                    .onTapGesture { selectedOrder = order }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Recommendations
    private var recommendationsSection: some View {
        let recs = catalogVM.recommendations(for: orderVM.orders)
        return Group {
            if !recs.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "wand.and.stars").foregroundColor(AppColors.accent)
                        Text("Based on your orders")
                            .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(recs) { book in
                                HomeBookCard(book: book)
                                    .onTapGesture {
                                        cartVM.add(book: book)
                                    }
                            }
                        }
                    }
                }
                .padding(14)
                .background(AppColors.surface)
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Buy again
    private func buyAgain(order: Order) {
        for item in order.items {
            if let book = catalogVM.allBooks.first(where: { $0.id == item.bookID }) {
                for _ in 0..<item.quantity {
                    cartVM.add(book: book, format: item.format)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.system(size: 64))
                .foregroundColor(AppColors.muted)
            Text("No orders yet")
                .font(.headline)
                .foregroundColor(.white)
            Text("Your order history will appear here once you've made a purchase.")
                .font(.subheadline)
                .foregroundColor(AppColors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Order card
struct OrderCard: View {
    let order: Order
    let onBuyAgain: () -> Void

    @State private var buyAgainConfirmed = false

    var statusColor: Color {
        switch order.status {
        case .processing: return .orange
        case .confirmed:  return .blue
        case .shipped:    return .purple
        case .delivered:  return .green
        case .cancelled:  return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Order #\(order.id.uuidString.prefix(8).uppercased())")
                        .font(.caption)
                        .foregroundColor(AppColors.muted)
                    Text(order.formattedDate)
                        .font(.caption)
                        .foregroundColor(AppColors.muted)
                }
                Spacer()
                Text(order.status.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .cornerRadius(6)
            }

            Divider().background(AppColors.border)

            // Items preview
            HStack(spacing: 10) {
                ForEach(order.items.prefix(3)) { item in
                    BookCoverView(
                        book: Book(id: item.bookID, title: item.title, author: item.author,
                                   description: "", price: item.price, originalPrice: nil,
                                   format: item.format, categories: [], coverColor: item.coverColor,
                                   rating: 4.5, reviewCount: 0, pageCount: 0, publisher: "",
                                   publishDate: Date(), isbn: "", isBestseller: false,
                                   isNewLaunch: false, isRecommended: false),
                        width: 48, height: 64
                    )
                }
                if order.items.count > 3 {
                    Text("+\(order.items.count - 3)")
                        .font(.caption)
                        .foregroundColor(AppColors.muted)
                        .frame(width: 48, height: 64)
                        .background(AppColors.surface2)
                        .cornerRadius(6)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₹\(String(format: "%.0f", order.totalAmount))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accent)
                    Text("\(order.items.count) item\(order.items.count == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundColor(AppColors.muted)
                }
            }

            Divider().background(AppColors.border)

            // Actions
            HStack(spacing: 12) {
                Text("View Details")
                    .font(.caption)
                    .foregroundColor(AppColors.accent)

                Spacer()

                Button {
                    onBuyAgain()
                    withAnimation { buyAgainConfirmed = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        buyAgainConfirmed = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: buyAgainConfirmed ? "checkmark" : "arrow.clockwise")
                            .font(.system(size: 11))
                        Text(buyAgainConfirmed ? "Added to Cart!" : "Buy Again")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(buyAgainConfirmed ? Color.green : AppColors.accent)
                    .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 1))
    }
}
