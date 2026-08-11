import SwiftUI

struct OrderDetailView: View {
    @State var order: Order
    @EnvironmentObject var orderVM:   OrderViewModel
    @EnvironmentObject var cartVM:    CartViewModel
    @EnvironmentObject var catalogVM: CatalogViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showCancelAlert = false
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
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Status card
                    statusCard

                    // Items
                    itemsCard

                    // Delivery & payment
                    infoCard

                    // Price summary
                    priceCard

                    // Actions
                    actionsSection

                    Spacer(minLength: 40)
                }
                .padding(16)
            }
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .alert("Cancel Order", isPresented: $showCancelAlert) {
            Button("Cancel Order", role: .destructive) {
                orderVM.cancelOrder(order)
                // Reflect local state
                if let updated = orderVM.orders.first(where: { $0.id == order.id }) {
                    order = updated
                }
            }
            Button("Keep Order", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this order? This action cannot be undone.")
        }
    }

    // MARK: - Status card
    private var statusCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(order.id.uuidString.prefix(8).uppercased())")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(order.formattedDate)
                        .font(.caption)
                        .foregroundColor(AppColors.muted)
                }
                Spacer()
                Text(order.status.rawValue)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.15))
                    .cornerRadius(8)
            }

            // Status timeline
            HStack(spacing: 0) {
                ForEach(statusSteps, id: \.label) { step in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(step.done ? statusColor : AppColors.border)
                            .frame(width: 10, height: 10)
                        Text(step.label)
                            .font(.system(size: 8))
                            .foregroundColor(step.done ? .white : AppColors.muted)
                    }
                    if step.label != statusSteps.last?.label {
                        Rectangle()
                            .fill(step.done ? statusColor : AppColors.border)
                            .frame(height: 2)
                            .padding(.bottom, 14)
                    }
                }
            }
        }
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    // MARK: - Items card
    private var itemsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items (\(order.items.count))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            ForEach(order.items) { item in
                HStack(spacing: 12) {
                    BookCoverView(
                        book: Book(id: item.bookID, title: item.title, author: item.author,
                                   description: "", price: item.price, originalPrice: nil,
                                   format: item.format, categories: [], coverColor: item.coverColor,
                                   rating: 4.5, reviewCount: 0, pageCount: 0, publisher: "",
                                   publishDate: Date(), isbn: "", isBestseller: false,
                                   isNewLaunch: false, isRecommended: false),
                        width: 56, height: 76
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        Text(item.author)
                            .font(.caption)
                            .foregroundColor(AppColors.muted)
                        Text(item.format.rawValue)
                            .font(.caption2)
                            .foregroundColor(AppColors.muted)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("₹\(Int(item.price))")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.accent)
                        Text("×\(item.quantity)")
                            .font(.caption2)
                            .foregroundColor(AppColors.muted)
                    }
                }
            }
        }
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    // MARK: - Info card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            infoRow(icon: "mappin.circle.fill",  label: "Delivery To",    value: order.addressLine)
            Divider().background(AppColors.border)
            infoRow(icon: "creditcard.fill",     label: "Payment",        value: order.paymentMethod)
            if order.giftPointsUsed > 0 {
                Divider().background(AppColors.border)
                infoRow(icon: "gift.fill", label: "Gift Points Used", value: "\(order.giftPointsUsed) pts")
            }
        }
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    // MARK: - Price card
    private var priceCard: some View {
        VStack(spacing: 8) {
            priceRow("Items",    "₹\(String(format: "%.0f", order.items.reduce(0) { $0 + $1.subtotal }))")
            priceRow("Delivery", "Free")
            if order.giftPointsUsed > 0 {
                priceRow("Gift Discount", "−₹\(String(format: "%.0f", Double(order.giftPointsUsed) / 10.0))", valueColor: .green)
            }
            Divider().background(AppColors.border)
            HStack {
                Text("Total Paid")
                    .font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                Spacer()
                Text("₹\(String(format: "%.0f", order.totalAmount))")
                    .font(.subheadline).fontWeight(.bold).foregroundColor(AppColors.accent)
            }
            HStack {
                Image(systemName: "gift.fill").foregroundColor(AppColors.accent).font(.caption)
                Text("\(order.pointsEarned) gift points earned from this order")
                    .font(.caption)
                    .foregroundColor(AppColors.muted)
            }
        }
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    // MARK: - Actions
    @ViewBuilder
    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Buy again
            Button {
                for item in order.items {
                    if let book = catalogVM.allBooks.first(where: { $0.id == item.bookID }) {
                        for _ in 0..<item.quantity { cartVM.add(book: book, format: item.format) }
                    }
                }
                withAnimation { buyAgainConfirmed = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { buyAgainConfirmed = false }
            } label: {
                HStack {
                    Image(systemName: buyAgainConfirmed ? "checkmark.circle.fill" : "arrow.clockwise")
                    Text(buyAgainConfirmed ? "Added to Cart!" : "Buy Again")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buyAgainConfirmed ? Color.green : AppColors.accent)
                .cornerRadius(12)
            }

            // Cancel order (within 48h)
            if order.canCancel {
                Button {
                    showCancelAlert = true
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Cancel Order")
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.12))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.4), lineWidth: 1))
                }

                HStack(spacing: 4) {
                    Image(systemName: "clock").font(.caption).foregroundColor(AppColors.muted)
                    Text("Orders can be cancelled within 48 hours of placing")
                        .font(.caption).foregroundColor(AppColors.muted)
                }
            }
        }
    }

    // MARK: - Helpers
    private var statusSteps: [StatusStep] {
        let allStatuses: [OrderStatus] = [.processing, .confirmed, .shipped, .delivered]
        guard order.status != .cancelled else {
            return [StatusStep(label: "Placed", done: true),
                    StatusStep(label: "Cancelled", done: true)]
        }
        let currentIndex = allStatuses.firstIndex(of: order.status) ?? 0
        return allStatuses.enumerated().map { idx, status in
            StatusStep(label: status.rawValue, done: idx <= currentIndex)
        }
    }

    struct StatusStep { let label: String; let done: Bool }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).foregroundColor(AppColors.accent).frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundColor(AppColors.muted)
                Text(value).font(.subheadline).foregroundColor(.white)
            }
        }
    }

    private func priceRow(_ label: String, _ value: String, valueColor: Color = .white) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundColor(AppColors.muted)
            Spacer()
            Text(value).font(.subheadline).foregroundColor(valueColor)
        }
    }
}
