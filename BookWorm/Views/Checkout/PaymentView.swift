import SwiftUI

struct PaymentView: View {
    @Binding var selectedPayment: String
    let total: Double
    
    private var paymentMethods: [PaymentMethod] {
        [
            PaymentMethod(id: "upi1",   icon: "qrcode",            label: "UPI",            detail: "raj@okicici"),
            PaymentMethod(id: "card1",  icon: "creditcard.fill",   label: "Credit Card",    detail: "•••• •••• •••• 4242"),
            PaymentMethod(id: "card2",  icon: "creditcard",        label: "Debit Card",     detail: "•••• •••• •••• 9191"),
            PaymentMethod(id: "nb1",    icon: "building.columns",  label: "Net Banking",    detail: "HDFC Bank"),
            PaymentMethod(id: "cod1",   icon: "indianrupeesign",   label: "Cash on Delivery", detail: "Pay ₹\(Int(total)) at door")
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Payment Method")
                .font(.headline)
                .foregroundColor(.white)
            
                // Amount to pay
            HStack {
                Text("Amount to Pay")
                    .font(.subheadline)
                    .foregroundColor(AppColors.muted)
                Spacer()
                Text("₹\(String(format: "%.0f", total))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.accent)
            }
            .padding(14)
            .background(AppColors.surface)
            .cornerRadius(12)
            
                // Payment options
            VStack(spacing: 10) {
                ForEach(paymentMethods) { method in
                    paymentRow(method)
                }
            }
            
                // Security note
            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill").foregroundColor(.green)
                Text("Payments are 100% secure and encrypted")
                    .font(.caption)
                    .foregroundColor(AppColors.muted)
            }
            .padding(.top, 4)
        }
    }
    
    private func paymentRow(_ method: PaymentMethod) -> some View {
        let isSelected = selectedPayment == "\(method.label) – \(method.detail)"
        return HStack(spacing: 12) {
            Image(systemName: method.icon)
                .font(.system(size: 22))
                .foregroundColor(isSelected ? AppColors.accent : AppColors.muted)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(method.label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(method.detail)
                    .font(.caption)
                    .foregroundColor(AppColors.muted)
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? AppColors.accent : AppColors.muted)
                .font(.system(size: 20))
        }
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? AppColors.accent.opacity(0.6) : AppColors.border, lineWidth: 1)
        )
        .onTapGesture {
            selectedPayment = "\(method.label) – \(method.detail)"
        }
    }
}

struct PaymentMethod: Identifiable {
    let id: String
    let icon: String
    let label: String
    let detail: String
}
