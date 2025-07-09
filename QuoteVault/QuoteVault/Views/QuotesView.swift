import SwiftUI

struct QuotesView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var searchText = ""
    @State private var showingFavoritesOnly = false
    @State private var selectedQuote: Quote?
    @State private var selectedBook: Book?
    
    private var filteredQuotes: [Quote] {
        var result = dataManager.quotes
        
        if showingFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }
        
        if !searchText.isEmpty {
            result = result.filter { quote in
                if quote.content.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
                
                if let book = dataManager.getBook(by: quote.bookID),
                   book.title.localizedCaseInsensitiveContains(searchText) || 
                   book.author.localizedCaseInsensitiveContains(searchText) {
                    return true
                }
                
                return false
            }
        }
        
        return result.sorted(by: { $0.dateAdded > $1.dateAdded })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.97, blue: 0.96),
                        Color(red: 0.96, green: 0.94, blue: 0.92)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Search Bar
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                            
                            TextField("Search quotes, books, or authors", text: $searchText)
                                .font(.system(size: 16, design: .serif))
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                        
                        // Filter Toggle
                        HStack {
                            Text("Filter:")
                                .font(.system(size: 14, design: .serif))
                                .foregroundColor(.secondary)
                            
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    showingFavoritesOnly.toggle()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: showingFavoritesOnly ? "heart.fill" : "heart")
                                        .font(.system(size: 14))
                                    Text("Favorites Only")
                                        .font(.system(size: 14, design: .serif))
                                }
                                .foregroundColor(showingFavoritesOnly ? .white : Color(hex: "8B7355"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(showingFavoritesOnly ? Color(hex: "8B7355") : Color(hex: "8B7355").opacity(0.1))
                                )
                            }
                            
                            Spacer()
                            
                            Text("\(filteredQuotes.count) quotes")
                                .font(.system(size: 14, design: .serif))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    
                    if filteredQuotes.isEmpty {
                        EmptyQuotesView(
                            showingFavoritesOnly: showingFavoritesOnly,
                            hasSearchText: !searchText.isEmpty
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredQuotes) { quote in
                                    if let book = dataManager.getBook(by: quote.bookID) {
                                        Button {
                                            selectedQuote = quote
                                            selectedBook = book
                                        } label: {
                                            ModernQuoteCard(
                                                quote: quote,
                                                book: book,
                                                onFavoriteToggle: {
                                                    withAnimation(.spring(response: 0.3)) {
                                                        dataManager.toggleFavorite(for: quote.id)
                                                    }
                                                }
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding(.vertical)
                            .padding(.bottom, 80)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Quotes")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(item: $selectedQuote) { quote in
                if let book = selectedBook {
                    QuoteDetailView(quote: quote, book: book)
                }
            }
        }
        .onAppear {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                .font: UIFont(name: "Georgia-Bold", size: 34)!
            ]
            UINavigationBar.appearance().titleTextAttributes = [
                .font: UIFont(name: "Georgia", size: 17)!
            ]
        }
    }
}

struct ModernQuoteCard: View {
    let quote: Quote
    let book: Book
    let onFavoriteToggle: () -> Void
    @State private var showingShare = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Quote Content
            Text(quote.content)
                .font(.system(size: 17, weight: .regular, design: .serif))
                .foregroundColor(.primary)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
            
            // Notes if available
            if let notes = quote.notes {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "note.text")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "8B7355"))
                        .padding(.top, 2)
                    
                    Text(notes)
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "F5F2ED"))
                )
            }
            
            // Bottom Section
            HStack {
                // Book Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        if let page = quote.page {
                            HStack(spacing: 4) {
                                Image(systemName: "book.pages")
                                    .font(.system(size: 11))
                                Text("Page \(page)")
                                    .font(.system(size: 12, design: .serif))
                            }
                            .foregroundColor(Color(hex: "8B7355"))
                        }
                        
                        if let chapter = quote.chapter {
                            HStack(spacing: 4) {
                                Image(systemName: "bookmark")
                                    .font(.system(size: 11))
                                Text(chapter)
                                    .font(.system(size: 12, design: .serif))
                            }
                            .foregroundColor(Color(hex: "8B7355"))
                        }
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: onFavoriteToggle) {
                        Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(quote.isFavorite ? .red : .gray)
                            .scaleEffect(quote.isFavorite ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3), value: quote.isFavorite)
                    }
                    
                    Button {
                        showingShare = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "8B7355"))
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
        .sheet(isPresented: $showingShare) {
            let pageText = quote.page != nil ? " (Page \(quote.page!))" : ""
            let textToShare = """
            "\(quote.content)"
            
            — \(book.author), \(book.title)\(pageText)
            """
            
            ShareSheet(activityItems: [textToShare])
        }
    }
}

struct EmptyQuotesView: View {
    let showingFavoritesOnly: Bool
    let hasSearchText: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: showingFavoritesOnly ? "heart.slash" : "quote.bubble")
                .font(.system(size: 70))
                .foregroundColor(Color(hex: "8B7355").opacity(0.5))
                .symbolRenderingMode(.hierarchical)
            
            Text(showingFavoritesOnly ? "No favorite quotes yet" : (hasSearchText ? "No matching quotes" : "No quotes yet"))
                .font(.system(size: 22, weight: .medium, design: .serif))
                .foregroundColor(.primary)
            
            Text(showingFavoritesOnly ? "Tap the heart on any quote to add it to favorites" : (hasSearchText ? "Try a different search term" : "Add some quotes from your books"))
                .font(.system(size: 16, design: .serif))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
} 