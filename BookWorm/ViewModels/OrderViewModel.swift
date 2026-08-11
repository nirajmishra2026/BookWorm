import Foundation
import CoreData
import Combine

class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadOrders()
    }

    // MARK: - Place Order
    @discardableResult
    func placeOrder(
        from cart: CartViewModel,
        address: String,
        paymentMethod: String,
        giftPointsUsed: Int
    ) -> Order? {
        guard !cart.items.isEmpty else { return nil }

        let orderEntity = OrderEntity(context: context)
        let orderID = UUID()
        orderEntity.id = orderID
        orderEntity.orderDate = Date()
        orderEntity.status = OrderStatus.confirmed.rawValue
        orderEntity.totalAmount = cart.total
        orderEntity.addressLine = address
        orderEntity.paymentMethod = paymentMethod
        orderEntity.giftPointsUsed = Int32(giftPointsUsed)

        var orderItems: [OrderItem] = []
        for cartItem in cart.items {
            let itemEntity = OrderItemEntity(context: context)
            itemEntity.bookID = cartItem.book.id
            itemEntity.title = cartItem.book.title
            itemEntity.author = cartItem.book.author
            itemEntity.format = cartItem.format.rawValue
            itemEntity.price = cartItem.book.price
            itemEntity.quantity = Int32(cartItem.quantity)
            itemEntity.coverColor = cartItem.book.coverColor.rawValue
            itemEntity.order = orderEntity

            orderItems.append(OrderItem(from: cartItem))
        }

        PersistenceController.shared.save()

        let order = Order(
            id: orderID,
            items: orderItems,
            orderDate: Date(),
            status: .confirmed,
            totalAmount: cart.total,
            addressLine: address,
            paymentMethod: paymentMethod,
            giftPointsUsed: giftPointsUsed
        )
        orders.insert(order, at: 0)
        return order
    }

    // MARK: - Cancel Order
    func cancelOrder(_ order: Order) {
        guard order.canCancel else { return }
        let request: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", order.id as CVarArg)
        if let entity = try? context.fetch(request).first {
            entity.status = OrderStatus.cancelled.rawValue
            PersistenceController.shared.save()
        }
        if let idx = orders.firstIndex(where: { $0.id == order.id }) {
            orders[idx].status = .cancelled
        }
    }

    // MARK: - Load
    func loadOrders() {
        let request: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "orderDate", ascending: false)]
        guard let entities = try? context.fetch(request) else { return }
        orders = entities.map { mapOrder(from: $0) }
    }

    // MARK: - Helpers
    private func mapOrder(from entity: OrderEntity) -> Order {
        let itemEntities = (entity.items as? Set<OrderItemEntity>) ?? []
        let items: [OrderItem] = itemEntities.map { itemEntity in
            OrderItem(
                bookID: itemEntity.bookID ?? UUID(),
                title: itemEntity.title ?? "",
                author: itemEntity.author ?? "",
                format: BookFormat(rawValue: itemEntity.format ?? "") ?? .paperback,
                price: itemEntity.price,
                quantity: Int(itemEntity.quantity),
                coverColor: BookCoverColor(rawValue: itemEntity.coverColor ?? "") ?? .blue
            )
        }.sorted { $0.title < $1.title }

        return Order(
            id: entity.id ?? UUID(),
            items: items,
            orderDate: entity.orderDate ?? Date(),
            status: OrderStatus(rawValue: entity.status ?? "") ?? .confirmed,
            totalAmount: entity.totalAmount,
            addressLine: entity.addressLine ?? "",
            paymentMethod: entity.paymentMethod ?? "",
            giftPointsUsed: Int(entity.giftPointsUsed)
        )
    }
}
