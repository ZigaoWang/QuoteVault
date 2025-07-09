import SwiftUI

struct BooksView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingAddBook = false
    @State private var showingAddQuote = false
    @State private var searchText = ""
    @State private var selectedBook: Book?
    
    private var filteredBooks: [Book] {
        if searchText.isEmpty {
            return dataManager.books
        } else {
            return dataManager.books.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var recentBooks: [Book] {
        return Array(dataManager.books.prefix(5))
    }
    
    private var lastReadBook: Book? {
        return dataManager.books.first
    }
    
    private var totalQuotes: Int {
        return dataManager.quotes.count
    }
    
    private var favoriteQuotes: Int {
        return dataManager.quotes.filter { $0.isFavorite }.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.97, blue: 0.96),
                        Color(red: 0.96, green: 0.94, blue: 0.92)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with greeting
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Good \(timeOfDay())")
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(.secondary)
                            
                            Text("Your Library")
                                .font(.system(size: 34, weight: .bold, design: .serif))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Stats Cards
                        statsSection
                        
                        // Continue Reading
                        if let lastBook = lastReadBook {
                            continueReadingSection(book: lastBook)
                        }
                        
                        // Books Grid
                        if !filteredBooks.isEmpty {
                            booksSection
                        }
                        
                        // Spacer for tab bar
                        Color.clear.frame(height: 80)
                    }
                }
                .scrollContentBackground(.hidden)
                .searchable(text: $searchText, prompt: "Search your library")
                
                if filteredBooks.isEmpty && !searchText.isEmpty {
                    emptySearchState
                } else if dataManager.books.isEmpty {
                    emptyLibraryState
                }
            }
            .navigationTitle("QuoteVault")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddBook = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showingAddBook) {
                AddBookView()
            }
            .sheet(isPresented: $showingAddQuote) {
                if let book = lastReadBook {
                    AddQuoteView(book: book)
                }
            }
            .navigationDestination(item: $selectedBook) { book in
                BookDetailView(book: book)
            }
        }
        .onAppear {
            // Force serif font for navigation title
            UINavigationBar.appearance().largeTitleTextAttributes = [
                .font: UIFont(name: "Georgia-Bold", size: 34)!
            ]
            UINavigationBar.appearance().titleTextAttributes = [
                .font: UIFont(name: "Georgia", size: 17)!
            ]
        }
    }
    
    private func timeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Morning"
        case 12..<17: return "Afternoon"
        default: return "Evening"
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Books",
                value: "\(dataManager.books.count)",
                icon: "books.vertical.fill",
                gradient: [Color(hex: "8B7355"), Color(hex: "6B5D54")]
            )
            
            StatCard(
                title: "Quotes",
                value: "\(totalQuotes)",
                icon: "quote.bubble.fill",
                gradient: [Color(hex: "A0826D"), Color(hex: "8B7355")]
            )
            
            StatCard(
                title: "Favorites",
                value: "\(favoriteQuotes)",
                icon: "heart.fill",
                gradient: [Color(hex: "BC9A6A"), Color(hex: "A0826D")]
            )
        }
        .padding(.horizontal)
    }
    
    private func continueReadingSection(book: Book) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Continue Reading")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            Button {
                selectedBook = book
            } label: {
                HStack(spacing: 16) {
                    // Book Cover
                    Group {
                        if let coverData = book.coverImage, let uiImage = UIImage(data: coverData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [Color(hex: "E8DCC6"), Color(hex: "DFD3C3")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 70, height: 100)
                                .overlay {
                                    Text(String(book.title.prefix(1)))
                                        .font(.system(size: 28, weight: .bold, design: .serif))
                                        .foregroundColor(Color(hex: "8B7355"))
                                }
                        }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // Book Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text(book.title)
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text("by \(book.author)")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "text.quote")
                                .font(.system(size: 12))
                            Text("\(dataManager.getQuotes(for: book.id).count) quotes")
                                .font(.system(size: 12, design: .serif))
                        }
                        .foregroundColor(Color(hex: "8B7355"))
                    }
                    
                    Spacer()
                    
                    // Quick Add Button
                    Button {
                        showingAddQuote = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: "8B7355"))
                            .background(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 28, height: 28)
                            )
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
        }
    }
    
    private var booksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Books")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(filteredBooks.count)")
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(filteredBooks) { book in
                    Button {
                        selectedBook = book
                    } label: {
                        BookGridItem(book: book, quotesCount: dataManager.getQuotes(for: book.id).count)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var emptySearchState: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No matching books")
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundColor(.primary)
            
            Text("Try a different search term")
                .font(.system(size: 16, design: .serif))
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyLibraryState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "8B7355").opacity(0.5))
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 12) {
                Text("Welcome to QuoteVault")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
                
                Text("Start building your personal library")
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                showingAddBook = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Your First Book")
                }
                .font(.system(size: 17, weight: .medium, design: .serif))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color(hex: "8B7355"), Color(hex: "6B5D54")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                )
            }
            
            Spacer()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .symbolRenderingMode(.hierarchical)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 14, design: .serif))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: gradient[0].opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}

struct BookGridItem: View {
    let book: Book
    let quotesCount: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // Book Cover
            Group {
                if let coverData = book.coverImage, let uiImage = UIImage(data: coverData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            colors: [Color(hex: "E8DCC6"), Color(hex: "DFD3C3")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 220)
                        .overlay {
                            Text(String(book.title.prefix(1)))
                                .font(.system(size: 48, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "8B7355"))
                        }
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Book Info
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(book.author)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 12))
                    Text("\(quotesCount)")
                        .font(.system(size: 12, design: .serif))
                }
                .foregroundColor(Color(hex: "8B7355"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 