import Foundation

struct Quote: Identifiable, Codable, Hashable {
    var id = UUID()
    var content: String
    var bookID: UUID
    var page: Int?
    var chapter: String?
    var dateAdded: Date = Date()
    var isFavorite: Bool = false
    var tags: [String] = []
    
    init(content: String, bookID: UUID, page: Int? = nil, chapter: String? = nil) {
        self.content = content
        self.bookID = bookID
        self.page = page
        self.chapter = chapter
    }
} 