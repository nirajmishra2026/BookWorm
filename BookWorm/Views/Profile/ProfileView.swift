import SwiftUI
import CoreData

struct ProfileView: View {
    @EnvironmentObject var authVM:  AuthViewModel
    @EnvironmentObject var orderVM: OrderViewModel
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showEditProfile = false
    @State private var editedName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Profile header
                        profileHeader

                        // Stats
                        statsRow

                        // Gift points card
                        giftPointsCard

                        // Menu items
                        menuSection

                        // Logout
                        logoutButton

                        Spacer(minLength: 40)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .sheet(isPresented: $showEditProfile) {
                editProfileSheet
            }
        }
    }

    // MARK: - Profile header
    private var profileHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.accent, AppColors.accent.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                Text(authVM.currentUser?.name.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.black)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(authVM.currentUser?.name ?? "")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(authVM.currentUser?.email ?? "")
                    .font(.caption)
                    .foregroundColor(AppColors.muted)

                // Membership tier badge
                if let user = authVM.currentUser {
                    Text(user.membershipTier + " Member")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(tierColor(user.membershipTier))
                        .cornerRadius(5)
                }
            }

            Spacer()

            Button {
                editedName = authVM.currentUser?.name ?? ""
                showEditProfile = true
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.accent)
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    // MARK: - Stats
    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(
                value: "\(orderVM.orders.filter { $0.status != .cancelled }.count)",
                label: "Orders"
            )
            Divider().background(AppColors.border).frame(height: 40)
            statItem(
                value: "\(authVM.currentUser?.giftPoints ?? 0)",
                label: "Gift Points"
            )
            Divider().background(AppColors.border).frame(height: 40)
            statItem(
                value: "₹\(Int(orderVM.orders.reduce(0) { $0 + $1.totalAmount }))",
                label: "Total Spent"
            )
        }
        .padding(.vertical, 14)
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppColors.accent)
            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.muted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Gift points card
    private var giftPointsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gift.fill").foregroundColor(AppColors.accent)
                Text("Gift Points")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(authVM.currentUser?.giftPoints ?? 0) pts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.accent)
            }

            // Points bar
            let points = authVM.currentUser?.giftPoints ?? 0
            let nextTierPoints = nextTierThreshold(points: points)
            let progress = min(Double(points) / Double(nextTierPoints), 1.0)

            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.border)
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.accent)
                            .frame(width: geo.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(points) / \(nextTierPoints) pts to next tier")
                    .font(.caption2)
                    .foregroundColor(AppColors.muted)
            }

            Text("Earn 1 point for every ₹10 spent. Redeem 10 points for ₹1 discount.")
                .font(.caption)
                .foregroundColor(AppColors.muted)
        }
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.accent.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Menu section
    private var menuSection: some View {
        VStack(spacing: 0) {
            menuItem(icon: "books.vertical.fill",     title: "Reading List",      subtitle: "Save books for later")
            Divider().background(AppColors.border).padding(.leading, 52)
            menuItem(icon: "bell.fill",               title: "Notifications",     subtitle: "Manage alerts")
            Divider().background(AppColors.border).padding(.leading, 52)
            menuItem(icon: "heart.fill",              title: "Wishlist",          subtitle: "Books you love")
            Divider().background(AppColors.border).padding(.leading, 52)
            menuItem(icon: "questionmark.circle.fill",title: "Help & Support",    subtitle: "FAQs and contact")
            Divider().background(AppColors.border).padding(.leading, 52)
            menuItem(icon: "doc.text.fill",           title: "Terms & Privacy",   subtitle: "Legal information")
        }
        .background(AppColors.surface)
        .cornerRadius(12)
    }

    private func menuItem(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(AppColors.muted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.muted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Logout
    private var logoutButton: some View {
        Button {
            authVM.logout()
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1))
        }
    }

    // MARK: - Edit profile sheet
    private var editProfileSheet: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    BWTextField(
                        placeholder: "Full name",
                        text: $editedName,
                        icon: "person.fill"
                    )
                    .padding(.horizontal, 16)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showEditProfile = false }
                        .foregroundColor(AppColors.muted)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Update user name in Core Data
                        if let user = authVM.currentUser, !editedName.isEmpty {
                            let request = UserEntity.fetchRequest()
                            request.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
                            if let entity = try? viewContext.fetch(request).first {
                                entity.name = editedName
                                PersistenceController.shared.save()
                                authVM.refreshUser()
                            }
                        }
                        showEditProfile = false
                    }
                    .foregroundColor(AppColors.accent)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Helpers
    private func tierColor(_ tier: String) -> Color {
        switch tier {
        case "Bronze":  return Color(red: 0.80, green: 0.50, blue: 0.20)
        case "Silver":  return Color(white: 0.70)
        case "Gold":    return AppColors.accent
        default:        return Color.cyan
        }
    }

    private func nextTierThreshold(points: Int) -> Int {
        if points < 100  { return 100 }
        if points < 500  { return 500 }
        if points < 1000 { return 1000 }
        return 2000
    }
}
