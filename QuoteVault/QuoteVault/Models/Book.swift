import Foundation

struct Book: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var author: String
    var coverImage: Data?
    var dateAdded: Date = Date()
    
    // For books added manually
    init(title: String, author: String, coverImage: Data? = nil) {
        self.title = title
        self.author = author
        self.coverImage = coverImage
    }
} 