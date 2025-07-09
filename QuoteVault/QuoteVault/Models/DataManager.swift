import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var books: [Book] = []
    @Published var quotes: [Quote] = []
    
    private let booksKey = "saved_books"
    private let quotesKey = "saved_quotes"
    
    init() {
        loadBooks()
        loadQuotes()
    }
    
    // MARK: - Book Methods
    
    func addBook(_ book: Book) {
        books.append(book)
        saveBooks()
    }
    
    func deleteBook(at offsets: IndexSet) {
        books.remove(atOffsets: offsets)
        saveBooks()
        
        // Remove all quotes associated with deleted books
        let remainingBookIDs = Set(books.map { $0.id })
        quotes = quotes.filter { remainingBookIDs.contains($0.bookID) }
        saveQuotes()
    }
    
    func getBook(by id: UUID) -> Book? {
        return books.first { $0.id == id }
    }
    
    // MARK: - Quote Methods
    
    func addQuote(_ quote: Quote) {
        quotes.append(quote)
        saveQuotes()
    }
    
    func deleteQuote(at offsets: IndexSet) {
        quotes.remove(atOffsets: offsets)
        saveQuotes()
    }
    
    func toggleFavorite(for quoteID: UUID) {
        if let index = quotes.firstIndex(where: { $0.id == quoteID }) {
            quotes[index].isFavorite.toggle()
            saveQuotes()
        }
    }
    
    func getQuotes(for bookID: UUID) -> [Quote] {
        return quotes.filter { $0.bookID == bookID }
    }
    
    // MARK: - Persistence
    
    private func saveBooks() {
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: booksKey)
        }
    }
    
    private func loadBooks() {
        if let data = UserDefaults.standard.data(forKey: booksKey),
           let decoded = try? JSONDecoder().decode([Book].self, from: data) {
            books = decoded
        }
    }
    
    private func saveQuotes() {
        if let encoded = try? JSONEncoder().encode(quotes) {
            UserDefaults.standard.set(encoded, forKey: quotesKey)
        }
    }
    
    private func loadQuotes() {
        if let data = UserDefaults.standard.data(forKey: quotesKey),
           let decoded = try? JSONDecoder().decode([Quote].self, from: data) {
            quotes = decoded
        }
    }
} 