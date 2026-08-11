import Foundation

struct CartItem: Identifiable, Hashable {
    let id: UUID
    let book: Book
    var quantity: Int
    var format: BookFormat

    var subtotal: Double {
        book.price * Double(quantity)
    }

    init(id: UUID = UUID(), book: Book, quantity: Int = 1, format: BookFormat? = nil) {
        self.id = id
        self.book = book
        self.quantity = quantity
        self.format = format ?? book.format
    }
}
