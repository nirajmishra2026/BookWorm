import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var cartVM:  CartViewModel
    @EnvironmentObject var orderVM: OrderViewModel
    @EnvironmentObject var authVM:  AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedAddress: String = "Home – 42 Bandra West, Mumbai, Maharashtra 400050"
    @State private var selectedPayment: String = "UPI – raj@okicici"
    @State private var step: CheckoutStep = .address
    @State private var placedOrder: Order? = nil
    @State private var showConfirmation = false

    enum CheckoutStep { case address, payment, review }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress indicator
                    progressBar

                    // Content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            switch step {
                            case .address:
                                AddressSelectionView(selectedAddress: $selectedAddress)
                            case .payment:
                                PaymentView(
                                    selectedPayment: $selectedPayment,
                                    total: cartVM.total
                                )
                            case .review:
                                reviewView
                            }
                            Spacer(minLength: 100)
                        }
                        .padding(16)
                    }

                    // Action bar
                    actionBar
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if step == .address { dismiss() }
                        else { step = step == .payment ? .address : .payment }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showConfirmation) {
            if let order = placedOrder {
                OrderConfirmationView(order: order)
                    .interactiveDismissDisabled()
                    .onDisappear { dismiss() }
            }
        }
    }

    // MARK: - Progress bar
    private var progressBar: some View {
        HStack(spacing: 0) {
            progressStep("Address",  icon: "mappin.circle.fill",  index: 0)
            progressLine(filled: step == .payment || step == .review)
            progressStep("Payment",  icon: "creditcard.fill",     index: 1)
            progressLine(filled: step == .review)
            progressStep("Review",   icon: "checkmark.circle.fill", index: 2)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(AppColors.surface)
    }

    private func progressStep(_ label: String, icon: String, index: Int) -> some View {
        let current = step == .address ? 0 : step == .payment ? 1 : 2
        let done = index < current
        let active = index == current
        return VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(done || active ? AppColors.accent : AppColors.muted)
            Text(label)
                .font(.caption2)
                .foregroundColor(done || active ? .white : AppColors.muted)
        }
    }

    private func progressLine(filled: Bool) -> some View {
        Rectangle()
            .frame(height: 2)
            .foregroundColor(filled ? AppColors.accent : AppColors.border)
            .padding(.bottom, 16)
    }

    // MARK: - Review
    private var reviewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionCard(title: "Delivery Address") {
                Text(selectedAddress)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }

            sectionCard(title: "Payment") {
                Text(selectedPayment)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }

            sectionCard(title: "Items (\(cartVM.itemCount))") {
                VStack(spacing: 8) {
                    ForEach(cartVM.items) { item in
                        HStack {
                            BookCoverView(book: item.book, width: 44, height: 60)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.book.title).font(.caption).foregroundColor(.white).lineLimit(1)
                                Text("Qty: \(item.quantity) × ₹\(Int(item.book.price))")
                                    .font(.caption2).foregroundColor(AppColors.muted)
                            }
                            Spacer()
                            Text("₹\(Int(item.subtotal))")
                                .font(.caption).fontWeight(.semibold).foregroundColor(AppColors.accent)
                        }
                    }
                }
            }

            sectionCard(title: "Price Breakdown") {
                VStack(spacing: 6) {
                    priceRow("Subtotal", "₹\(Int(cartVM.subtotal))")
                    priceRow("Delivery", "Free")
                    if cartVM.appliedGiftPoints > 0 {
                        priceRow("Gift Points", "−₹\(String(format: "%.0f", cartVM.giftPointsDiscount))", valueColor: .green)
                    }
                    Divider().background(AppColors.border)
                    HStack {
                        Text("Total").font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                        Spacer()
                        Text("₹\(String(format: "%.0f", cartVM.total))")
                            .font(.subheadline).fontWeight(.bold).foregroundColor(AppColors.accent)
                    }
                }
            }
        }
    }

    // MARK: - Action bar
    private var actionBar: some View {
        VStack(spacing: 0) {
            Divider().background(AppColors.border)
            Button {
                switch step {
                case .address: step = .payment
                case .payment: step = .review
                case .review:  placeOrder()
                }
            } label: {
                Text(step == .review ? "Place Order  ₹\(String(format: "%.0f", cartVM.total))" : "Continue")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.accent)
                    .cornerRadius(0)
            }
        }
    }

    // MARK: - Place order
    private func placeOrder() {
        let order = orderVM.placeOrder(
            from: cartVM,
            address: selectedAddress,
            paymentMethod: selectedPayment,
            giftPointsUsed: cartVM.appliedGiftPoints
        )
        if let order = order {
            let points = order.pointsEarned
            if cartVM.appliedGiftPoints > 0 {
                authVM.deductGiftPoints(cartVM.appliedGiftPoints)
            }
            authVM.addGiftPoints(points)
            cartVM.clearCart()
            placedOrder = order
            showConfirmation = true
        }
    }

    // MARK: - Helpers
    @ViewBuilder
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    private func priceRow(_ label: String, _ value: String, valueColor: Color = .white) -> some View {
        HStack {
            Text(label).font(.caption).foregroundColor(AppColors.muted)
            Spacer()
            Text(value).font(.caption).foregroundColor(valueColor)
        }
    }
}

// MARK: - Confirmation sheet
struct OrderConfirmationView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)

                VStack(spacing: 8) {
                    Text("Order Placed!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Your books are on their way.")
                        .font(.subheadline)
                        .foregroundColor(AppColors.muted)
                    Text("Order ID: \(order.id.uuidString.prefix(8).uppercased())")
                        .font(.caption)
                        .foregroundColor(AppColors.muted)
                }

                VStack(spacing: 10) {
                    rewardRow(icon: "gift.fill",
                              text: "+\(order.pointsEarned) gift points earned!")
                    rewardRow(icon: "shippingbox.fill",
                              text: "Estimated delivery in 5 days")
                }
                .padding(16)
                .background(AppColors.surface)
                .cornerRadius(12)
                .padding(.horizontal, 24)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Continue Shopping")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accent)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }

    private func rewardRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(AppColors.accent)
            Text(text).font(.subheadline).foregroundColor(.white)
            Spacer()
        }
    }
}
