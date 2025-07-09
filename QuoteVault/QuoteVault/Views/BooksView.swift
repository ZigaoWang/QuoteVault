import SwiftUI

struct BooksView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingAddBook = false
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
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 0.96, green: 0.94, blue: 0.90), location: 0.0),
                        .init(color: Color(red: 0.94, green: 0.91, blue: 0.87), location: 0.5),
                        .init(color: Color(red: 0.92, green: 0.89, blue: 0.85), location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        statsSection
                        
                        if let lastBook = lastReadBook {
                            continueReadingSection(book: lastBook)
                        }
                        
                        if !filteredBooks.isEmpty {
                            booksSection
                        }
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 60)
                    }
                    .padding(.top, 20)
                }
                .searchable(text: $searchText, prompt: "Search your library")
                
                if filteredBooks.isEmpty && !searchText.isEmpty {
                    emptySearchState
                } else if dataManager.books.isEmpty {
                    emptyLibraryState
                }
            }
            .navigationTitle("QuoteVault")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddBook = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.brown.opacity(0.8))
                    }
                }
            }
            .sheet(isPresented: $showingAddBook) {
                AddBookView()
            }
            .navigationDestination(item: $selectedBook) { book in
                BookDetailView(book: book)
            }
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Books",
                value: "\(dataManager.books.count)",
                icon: "books.vertical",
                color: .blue
            )
            
            StatCard(
                title: "Quotes",
                value: "\(totalQuotes)",
                icon: "text.quote",
                color: .green
            )
            
            StatCard(
                title: "Favorites",
                value: "\(favoriteQuotes)",
                icon: "heart.fill",
                color: .red
            )
        }
        .padding(.horizontal, 20)
    }
    
    private func continueReadingSection(book: Book) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Continue Reading")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundColor(.brown.opacity(0.8))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            Button {
                selectedBook = book
            } label: {
                HStack(spacing: 16) {
                    if let coverData = book.coverImage, let uiImage = UIImage(data: coverData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 80)
                            .cornerRadius(6)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 80)
                            .cornerRadius(6)
                            .overlay {
                                Text(String(book.title.prefix(1)))
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                                    .foregroundColor(.gray)
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Text("by \(book.author)")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(.secondary)
                        
                        Text("\(dataManager.getQuotes(for: book.id).count) quotes")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(.brown.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Button {
                            selectedBook = book
                        } label: {
                            Text("Add Quote")
                                .font(.system(size: 14, weight: .medium, design: .serif))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.brown.opacity(0.8))
                                )
                        }
                        
                        Button {
                            selectedBook = book
                        } label: {
                            Text("View Book")
                                .font(.system(size: 14, weight: .medium, design: .serif))
                                .foregroundColor(.brown.opacity(0.8))
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
        }
    }
    
    private var booksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Library")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundColor(.brown.opacity(0.8))
                
                Spacer()
                
                if dataManager.books.count > 5 {
                    Button("See All") {
                        
                    }
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(.brown.opacity(0.6))
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recentBooks, id: \.id) { book in
                        Button {
                            selectedBook = book
                        } label: {
                            BookCoverView(book: book)
                                .frame(height: 200)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var emptySearchState: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.brown.opacity(0.5))
            
            Text("No matching books")
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundColor(.brown.opacity(0.8))
            
            Text("Try a different search term")
                .font(.system(size: 16, design: .serif))
                .foregroundColor(.brown.opacity(0.6))
        }
    }
    
    private var emptyLibraryState: some View {
        VStack(spacing: 30) {
            Image(systemName: "books.vertical")
                .font(.system(size: 80))
                .foregroundColor(.brown.opacity(0.6))
            
            Text("Welcome to QuoteVault")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.brown.opacity(0.8))
            
            Text("Start building your personal library of wisdom")
                .font(.system(size: 18, design: .serif))
                .foregroundColor(.brown.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddBook = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Your First Book")
                }
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.brown.opacity(0.8))
                )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 14, design: .serif))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
} 