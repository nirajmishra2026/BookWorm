import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var authVM    : AuthViewModel
    @StateObject private var catalogVM : CatalogViewModel
    @StateObject private var cartVM    : CartViewModel
    @StateObject private var orderVM   : OrderViewModel

    @State private var selectedTab: Tab = .home

    init() {
        let ctx = PersistenceController.shared.container.viewContext
        _authVM    = StateObject(wrappedValue: AuthViewModel(context: ctx))
        _catalogVM = StateObject(wrappedValue: CatalogViewModel())
        _cartVM    = StateObject(wrappedValue: CartViewModel(context: ctx))
        _orderVM   = StateObject(wrappedValue: OrderViewModel(context: ctx))
    }

    enum Tab: Hashable {
        case home, catalog, cart, orders, profile
    }

    var body: some View {
        Group {
            if authVM.isAuthenticated {
                mainTabView
            } else {
                LoginView()
                    .environmentObject(authVM)
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .environmentObject(catalogVM)
                .environmentObject(cartVM)
                .tabItem { Label("Home",    systemImage: "house.fill") }
                .tag(Tab.home)

            CatalogView()
                .environmentObject(catalogVM)
                .environmentObject(cartVM)
                .tabItem { Label("Catalog", systemImage: "books.vertical.fill") }
                .tag(Tab.catalog)

            CartView()
                .environmentObject(cartVM)
                .environmentObject(orderVM)
                .environmentObject(authVM)
                .tabItem { Label("Cart",    systemImage: "cart.fill") }
                .badge(cartVM.itemCount > 0 ? cartVM.itemCount : 0)
                .tag(Tab.cart)

            OrderHistoryView()
                .environmentObject(orderVM)
                .environmentObject(cartVM)
                .environmentObject(catalogVM)
                .tabItem { Label("Orders",  systemImage: "shippingbox.fill") }
                .tag(Tab.orders)

            ProfileView()
                .environmentObject(authVM)
                .environmentObject(orderVM)
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(Tab.profile)
        }
        .accentColor(AppColors.accent)
    }
}

#Preview {
    ContentView()
}
