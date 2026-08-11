import Foundation

struct Order: Identifiable, Hashable {
    let id: UUID
    let items: [OrderItem]
    let orderDate: Date
    var status: OrderStatus
    let totalAmount: Double
    let addressLine: String
    let paymentMethod: String
    let giftPointsUsed: Int

    var canCancel: Bool {
        guard status == .processing || status == .confirmed else { return false }
        let hours = Calendar.current.dateComponents([.hour], from: orderDate, to: Date()).hour ?? 0
        return hours < 48
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: orderDate)
    }

    var pointsEarned: Int {
        Int(totalAmount / 10)
    }
}

struct OrderItem: Identifiable, Hashable {
    let id: UUID
    let bookID: UUID
    let title: String
    let author: String
    let format: BookFormat
    let price: Double
    let quantity: Int
    let coverColor: BookCoverColor

    var subtotal: Double { price * Double(quantity) }

    init(id: UUID = UUID(), bookID: UUID, title: String, author: String,
         format: BookFormat, price: Double, quantity: Int, coverColor: BookCoverColor) {
        self.id = id
        self.bookID = bookID
        self.title = title
        self.author = author
        self.format = format
        self.price = price
        self.quantity = quantity
        self.coverColor = coverColor
    }

    init(from cartItem: CartItem) {
        self.id = UUID()
        self.bookID = cartItem.book.id
        self.title = cartItem.book.title
        self.author = cartItem.book.author
        self.format = cartItem.format
        self.price = cartItem.book.price
        self.quantity = cartItem.quantity
        self.coverColor = cartItem.book.coverColor
    }
}

enum OrderStatus: String, Codable {
    case processing = "Processing"
    case confirmed = "Confirmed"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"

    var color: String {
        switch self {
        case .processing: return "orange"
        case .confirmed:  return "blue"
        case .shipped:    return "purple"
        case .delivered:  return "green"
        case .cancelled:  return "red"
        }
    }
}
