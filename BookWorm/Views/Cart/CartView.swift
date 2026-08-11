import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartVM:  CartViewModel
    @EnvironmentObject var orderVM: OrderViewModel
    @EnvironmentObject var authVM:  AuthViewModel

    @State private var showCheckout = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if cartVM.isEmpty {
                    emptyCartView
                } else {
                    cartContent
                }
            }
            .navigationTitle("My Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .sheet(isPresented: $showCheckout) {
                CheckoutView()
                    .environmentObject(cartVM)
                    .environmentObject(orderVM)
                    .environmentObject(authVM)
            }
        }
    }

    // MARK: - Cart Content
    private var cartContent: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(cartVM.items) { item in
                        CartItemRow(item: item)
                            .environmentObject(cartVM)
                    }

                    // Gift points section
                    if let user = authVM.currentUser, user.giftPoints > 0 {
                        giftPointsSection(user: user)
                    }

                    // Order summary
                    orderSummary
                }
                .padding(16)
                .padding(.bottom, 100)
            }

            // Checkout bar
            checkoutBar
        }
    }

    // MARK: - Gift points
    private func giftPointsSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gift.fill").foregroundColor(AppColors.accent)
                Text("Gift Points")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Text("Available: \(user.giftPoints) pts")
                    .font(.caption)
                    .foregroundColor(AppColors.accent)
            }

            if cartVM.appliedGiftPoints > 0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    Text("\(cartVM.appliedGiftPoints) pts applied (−₹\(String(format: "%.0f", cartVM.giftPointsDiscount)))")
                        .font(.caption)
                        .foregroundColor(.green)
                    Spacer()
                    Button("Remove") {
                        cartVM.removeGiftPoints()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            } else {
                Button {
                    cartVM.applyGiftPoints(user.giftPoints, available: user.giftPoints)
                } label: {
                    Text("Apply \(user.giftPoints) gift points (save ₹\(String(format: "%.0f", min(Double(user.giftPoints) / 10.0, cartVM.subtotal))))")
                        .font(.caption)
                        .foregroundColor(AppColors.accent)
                }
            }
        }
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.accent.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Order summary
    private var orderSummary: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Order Summary")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
            }

            summaryRow("Subtotal (\(cartVM.itemCount) items)", "₹\(String(format: "%.0f", cartVM.subtotal))")
            summaryRow("Delivery", "Free")

            if cartVM.appliedGiftPoints > 0 {
                summaryRow("Gift Points Discount", "−₹\(String(format: "%.0f", cartVM.giftPointsDiscount))", color: .green)
            }

            Divider().background(AppColors.border)

            HStack {
                Text("Total")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("₹\(String(format: "%.0f", cartVM.total))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.accent)
            }
        }
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    private func summaryRow(_ label: String, _ value: String, color: Color = .white) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.muted)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(color)
        }
    }

    // MARK: - Checkout bar
    private var checkoutBar: some View {
        VStack(spacing: 0) {
            Divider().background(AppColors.border)
            Button {
                showCheckout = true
            } label: {
                HStack {
                    Text("Proceed to Checkout")
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    Text("₹\(String(format: "%.0f", cartVM.total))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .padding()
                .background(AppColors.accent)
                .cornerRadius(0)
            }
        }
    }

    // MARK: - Empty state
    private var emptyCartView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 64))
                .foregroundColor(AppColors.muted)
            Text("Your cart is empty")
                .font(.headline)
                .foregroundColor(.white)
            Text("Browse the catalog and add some books!")
                .font(.subheadline)
                .foregroundColor(AppColors.muted)
        }
    }
}
