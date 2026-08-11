import Foundation
import CoreData
import Combine

class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var appliedGiftPoints: Int = 0

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadCart()
    }

    // MARK: - Computed
    var subtotal: Double        { items.reduce(0) { $0 + $1.subtotal } }
    var giftPointsDiscount: Double { Double(appliedGiftPoints) / 10.0 }
    var total: Double           { max(0, subtotal - giftPointsDiscount) }
    var itemCount: Int          { items.reduce(0) { $0 + $1.quantity } }
    var isEmpty: Bool           { items.isEmpty }

    // MARK: - Add
    func add(book: Book, format: BookFormat? = nil) {
        let fmt = format ?? book.format
        if let idx = items.firstIndex(where: { $0.book.id == book.id && $0.format == fmt }) {
            items[idx].quantity += 1
        } else {
            items.append(CartItem(book: book, quantity: 1, format: fmt))
        }
        persistCart()
    }

    // MARK: - Remove
    func remove(item: CartItem) {
        items.removeAll { $0.id == item.id }
        persistCart()
    }

    func decreaseQuantity(of item: CartItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            if items[idx].quantity > 1 {
                items[idx].quantity -= 1
            } else {
                items.remove(at: idx)
            }
            persistCart()
        }
    }

    func increaseQuantity(of item: CartItem) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx].quantity += 1
            persistCart()
        }
    }

    func clearCart() {
        items.removeAll()
        appliedGiftPoints = 0
        clearPersistedCart()
    }

    // MARK: - Gift Points
    func applyGiftPoints(_ points: Int, available: Int) {
        let maxApplicable = Int(subtotal * 10)
        appliedGiftPoints = min(points, min(available, maxApplicable))
    }

    func removeGiftPoints() {
        appliedGiftPoints = 0
    }

    // MARK: - Persistence
    private func loadCart() {
        let request: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        guard let entities = try? context.fetch(request) else { return }
        items = entities.compactMap { entity -> CartItem? in
            guard let bookID = entity.bookID,
                  let book = SampleData.books.first(where: { $0.id == bookID }) else { return nil }
            let format = BookFormat(rawValue: entity.format ?? "") ?? book.format
            return CartItem(id: UUID(), book: book, quantity: Int(entity.quantity), format: format)
        }
    }

    private func persistCart() {
        let request: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        if let existing = try? context.fetch(request) {
            existing.forEach { context.delete($0) }
        }
        for item in items {
            let entity = CartItemEntity(context: context)
            entity.bookID = item.book.id
            entity.title = item.book.title
            entity.author = item.book.author
            entity.format = item.format.rawValue
            entity.price = item.book.price
            entity.quantity = Int32(item.quantity)
            entity.coverColor = item.book.coverColor.rawValue
            entity.deliveryDate = item.book.deliveryDate
        }
        PersistenceController.shared.save()
    }

    private func clearPersistedCart() {
        let request: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        if let existing = try? context.fetch(request) {
            existing.forEach { context.delete($0) }
        }
        PersistenceController.shared.save()
    }
}
