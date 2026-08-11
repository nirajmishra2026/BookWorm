import Foundation
import SwiftUI

struct Book: Identifiable, Hashable {
    let id: UUID
    let title: String
    let author: String
    let description: String
    let price: Double
    let originalPrice: Double?
    let format: BookFormat
    let categories: [String]
    let coverColor: BookCoverColor
    let rating: Double
    let reviewCount: Int
    let pageCount: Int
    let publisher: String
    let publishDate: Date
    let isbn: String
    var isBestseller: Bool
    var isNewLaunch: Bool
    var isRecommended: Bool

    var deliveryDate: Date {
        Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
    }

    var formattedDeliveryDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM"
        return formatter.string(from: deliveryDate)
    }

    var discountPercentage: Int? {
        guard let original = originalPrice, original > price else { return nil }
        return Int(((original - price) / original) * 100)
    }
}

enum BookFormat: String, CaseIterable, Hashable {
    case paperback = "Paperback"
    case hardcover = "Hardcover"
    case ebook = "eBook"
}

enum BookCoverColor: String, CaseIterable, Hashable {
    case blue = "blue"
    case purple = "purple"
    case green = "green"
    case orange = "orange"
    case red = "red"
    case teal = "teal"
    case indigo = "indigo"
    case pink = "pink"
    case yellow = "yellow"
    case brown = "brown"

    var color: Color {
        switch self {
        case .blue:   return Color(red: 0.20, green: 0.40, blue: 0.80)
        case .purple: return Color(red: 0.50, green: 0.20, blue: 0.75)
        case .green:  return Color(red: 0.15, green: 0.60, blue: 0.40)
        case .orange: return Color(red: 0.90, green: 0.50, blue: 0.10)
        case .red:    return Color(red: 0.80, green: 0.15, blue: 0.20)
        case .teal:   return Color(red: 0.10, green: 0.60, blue: 0.65)
        case .indigo: return Color(red: 0.30, green: 0.25, blue: 0.70)
        case .pink:   return Color(red: 0.85, green: 0.30, blue: 0.55)
        case .yellow: return Color(red: 0.90, green: 0.75, blue: 0.10)
        case .brown:  return Color(red: 0.55, green: 0.35, blue: 0.15)
        }
    }

    var secondaryColor: Color {
        switch self {
        case .blue:   return Color(red: 0.10, green: 0.25, blue: 0.55)
        case .purple: return Color(red: 0.30, green: 0.10, blue: 0.50)
        case .green:  return Color(red: 0.08, green: 0.40, blue: 0.25)
        case .orange: return Color(red: 0.70, green: 0.30, blue: 0.05)
        case .red:    return Color(red: 0.55, green: 0.08, blue: 0.10)
        case .teal:   return Color(red: 0.05, green: 0.40, blue: 0.45)
        case .indigo: return Color(red: 0.18, green: 0.14, blue: 0.50)
        case .pink:   return Color(red: 0.65, green: 0.15, blue: 0.35)
        case .yellow: return Color(red: 0.70, green: 0.55, blue: 0.05)
        case .brown:  return Color(red: 0.35, green: 0.20, blue: 0.08)
        }
    }
}

let allCategories: [String] = [
    "All", "Romance", "Mystery", "Science Fiction", "Fantasy",
    "Historical", "Biography", "Self-help", "Memoir", "Travel",
    "Cooking", "Children's", "Young Adult", "Comics & Graphic Novels",
    "Poetry", "Drama", "Science", "Philosophy", "Religion", "Language Learning"
]
