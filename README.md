# BookWorm

A feature-rich iOS bookstore app built with **SwiftUI** and **Core Data**. BookWorm lets users browse a curated book catalog, manage a shopping cart, and place orders — all with a dark-mode-first UI and a loyalty gift points system.

---

## Features

### Authentication
- Sign up with name, email, and password (minimum 6 characters)
- Login with email/password validation
- Persistent session stored in Core Data — stays logged in across app launches
- New users receive **50 welcome gift points** on registration

### Home
- Hero banner highlighting the welcome gift points offer
- Curated sections: **Recommended for You**, **Bestsellers**, and **New Launches**
- Tap any book card to navigate to the full detail view
- Cart badge shortcut in the navigation bar

### Catalog
- Full browsable book catalog with **20 genre categories** (Romance, Mystery, Sci-Fi, Fantasy, Self-help, and more)
- **Search** by title, author, or category
- **Sort** by Relevance, Price (Low/High), Top Rated, or Newest
- Category filter pill strip for quick genre browsing

### Book Detail
- Colorful, dynamically generated book cover (gradient + spine effect)
- Rating, review count, page count, publisher, ISBN, and publish date
- Format selector (Paperback / Hardcover / eBook)
- Estimated delivery date (5 days from today)
- Bestseller / New Launch / Recommended badges
- Discount percentage display when an original price is present

### Cart
- Add/remove items or adjust quantity
- Persisted via Core Data — cart survives app restarts
- Apply available **gift points** as a discount (10 points = ₹1)
- Live price breakdown: subtotal, gift points deduction, and total

### Checkout (3-step flow)
| Step | Description |
|------|-------------|
| **Address** | Select a delivery address |
| **Payment** | Choose a payment method (UPI, Card, etc.) |
| **Review** | Confirm items, address, payment, and final total |

- Places order and shows an **Order Confirmation** sheet
- Automatically earns gift points on every order (1 point per ₹10 spent)
- Applied gift points are deducted from the user's balance on successful order

### Order History
- Full list of past orders sorted by most recent
- Order statuses: Processing → Confirmed → Shipped → Delivered (or Cancelled)
- **Cancel** an order within 48 hours if status is Processing or Confirmed
- Personalised recommendations based on categories in order history

### Profile
- Displays user name, email, and join date
- **Membership tier** based on gift points balance:
  | Points | Tier |
  |--------|------|
  | 0–99 | Bronze |
  | 100–499 | Silver |
  | 500–999 | Gold |
  | 1000+ | Platinum |
- Logout

---

## Architecture

```
BookWorm/
├── Models/           # Pure Swift value types (Book, CartItem, Order, User)
├── ViewModels/       # ObservableObject classes (Auth, Catalog, Cart, Order)
├── Views/
│   ├── Auth/         # LoginView, SignUpView
│   ├── Catalog/      # CatalogView, BookCardView, BookDetailView
│   ├── Cart/         # CartView, CartItemRow
│   ├── Checkout/     # CheckoutView, AddressSelectionView, PaymentView
│   ├── Orders/       # OrderHistoryView, OrderDetailView
│   ├── Profile/      # ProfileView
│   └── Main/         # ContentView (tab bar), HomeView
├── CoreData/         # PersistenceController + BookWormDataModel schema
└── Utilities/        # SampleData (static book catalogue)
```

The app follows an **MVVM** pattern:
- **Models** are plain `struct` types — `Identifiable`, `Hashable`, no SwiftUI dependencies.
- **ViewModels** are `ObservableObject` classes injected as `@EnvironmentObject` down the view hierarchy.
- **Core Data** is used exclusively for persistence (user session, cart, orders). The in-memory book catalog is provided by `SampleData`.

---

## Tech Stack

| Technology | Usage |
|---|---|
| SwiftUI | Entire UI layer |
| Core Data | User, cart, and order persistence |
| Combine | `@Published` / `ObservableObject` reactive bindings |
| Swift 5 | Language |
| iOS 17+ | Minimum deployment target (uses `NavigationStack`, `navigationDestination(item:)`) |

---

## Getting Started

1. Clone the repo and open `BookWorm.xcodeproj` in Xcode 15 or later.
2. Select an iOS 17+ simulator or a connected device.
3. Build and run (`⌘R`). No additional dependencies or API keys are required.

> **Note:** The book catalog is static sample data defined in [`SampleData.swift`](BookWorm/Utilities/SampleData.swift). The password hashing in `AuthViewModel` is a simple FNV-1a demo hash — not suitable for production.

---

## Project Structure at a Glance

| File | Responsibility |
|---|---|
| `BookWormApp.swift` | App entry point, Core Data context injection |
| `PersistenceController.swift` | Singleton NSPersistentContainer wrapper |
| `ContentView.swift` | Root view — auth gate + 5-tab navigation |
| `HomeView.swift` | Hero banner + curated book sections |
| `CatalogViewModel.swift` | Search, filter, and sort logic |
| `CartViewModel.swift` | Cart state, gift points, Core Data persistence |
| `OrderViewModel.swift` | Place/cancel orders, Core Data persistence |
| `AuthViewModel.swift` | Sign up, login, logout, gift point management |
