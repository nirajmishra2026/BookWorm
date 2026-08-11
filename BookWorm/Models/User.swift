import Foundation

struct User: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var giftPoints: Int
    let joinDate: Date

    var membershipTier: String {
        switch giftPoints {
        case 0..<100:    return "Bronze"
        case 100..<500:  return "Silver"
        case 500..<1000: return "Gold"
        default:         return "Platinum"
        }
    }

    var tierColor: String {
        switch membershipTier {
        case "Bronze":   return "brown"
        case "Silver":   return "gray"
        case "Gold":     return "yellow"
        default:         return "cyan"
        }
    }
}
