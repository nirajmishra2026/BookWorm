import SwiftUI

struct AddressSelectionView: View {
    @Binding var selectedAddress: String

    private let addresses = [
        "Home – 42 Bandra West, Mumbai, Maharashtra 400050",
        "Office – 12 Connaught Place, New Delhi, Delhi 110001",
        "Family – 8 Koramangala Block 5, Bengaluru, Karnataka 560095",
        "Friend – 3 Park Street, Kolkata, West Bengal 700016"
    ]

    @State private var showAddNew = false
    @State private var newAddress = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Delivery Address")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 10) {
                ForEach(addresses, id: \.self) { address in
                    addressRow(address)
                }
                if !newAddress.isEmpty {
                    addressRow(newAddress)
                }
            }

            // Add new address
            if showAddNew {
                VStack(spacing: 10) {
                    BWTextField(
                        placeholder: "Enter new address",
                        text: $newAddress,
                        icon: "mappin.and.ellipse"
                    )
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            showAddNew = false
                            newAddress = ""
                        }
                        .font(.subheadline)
                        .foregroundColor(AppColors.muted)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.surface)
                        .cornerRadius(10)

                        Button("Save") {
                            if !newAddress.isEmpty {
                                selectedAddress = newAddress
                            }
                            showAddNew = false
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accent)
                        .cornerRadius(10)
                    }
                }
            } else {
                Button {
                    showAddNew = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add New Address")
                    }
                    .font(.subheadline)
                    .foregroundColor(AppColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.accent.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
            }
        }
    }

    private func addressRow(_ address: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: selectedAddress == address ? "checkmark.circle.fill" : "circle")
                .foregroundColor(selectedAddress == address ? AppColors.accent : AppColors.muted)
                .font(.system(size: 20))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                let parts = address.components(separatedBy: " – ")
                if parts.count == 2 {
                    Text(parts[0])
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text(parts[1])
                        .font(.caption)
                        .foregroundColor(AppColors.muted)
                } else {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(selectedAddress == address ? AppColors.accent.opacity(0.6) : AppColors.border, lineWidth: 1)
        )
        .onTapGesture {
            selectedAddress = address
        }
    }
}
