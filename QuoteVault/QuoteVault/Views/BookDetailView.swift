import SwiftUI

struct BookDetailView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingAddQuote = false
    @State private var searchText = ""
    @State private var selectedQuote: Quote?
    
    let book: Book
    
    private var filteredQuotes: [Quote] {
        let bookQuotes = dataManager.getQuotes(for: book.id)
        
        if searchText.isEmpty {
            return bookQuotes
        } else {
            return bookQuotes.filter { quote in
                quote.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Book Header Card
                    VStack(spacing: 20) {
                        HStack(alignment: .top, spacing: 20) {
                            // Book Cover
                            Group {
                                if let coverData = book.coverImage, let uiImage = UIImage(data: coverData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(LinearGradient(
                                            colors: [Color(hex: "E8DCC6"), Color(hex: "DFD3C3")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 120, height: 180)
                                        .overlay {
                                            Text(String(book.title.prefix(1)))
                                                .font(.system(size: 48, weight: .bold, design: .serif))
                                                .foregroundColor(Color(hex: "8B7355"))
                                        }
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                }
                            }
                            
                            // Book Info
                            VStack(alignment: .leading, spacing: 12) {
                                Text(book.title)
                                    .font(.system(size: 24, weight: .bold, design: .serif))
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("by \(book.author)")
                                    .font(.system(size: 18, design: .serif))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                // Stats
                                HStack(spacing: 20) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(filteredQuotes.count)")
                                            .font(.system(size: 24, weight: .bold, design: .serif))
                                            .foregroundColor(Color(hex: "8B7355"))
                                        Text("Quotes")
                                            .font(.system(size: 14, design: .serif))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(filteredQuotes.filter { $0.isFavorite }.count)")
                                            .font(.system(size: 24, weight: .bold, design: .serif))
                                            .foregroundColor(.red)
                                        Text("Favorites")
                                            .font(.system(size: 14, design: .serif))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Add Quote Button
                        Button {
                            showingAddQuote = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add New Quote")
                            }
                            .font(.system(size: 16, weight: .medium, design: .serif))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient(
                                        colors: [Color(hex: "8B7355"), Color(hex: "6B5D54")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                            )
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                    )
                    .padding(.horizontal)
                    
                    // Search Bar
                    if !dataManager.getQuotes(for: book.id).isEmpty {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                            
                            TextField("Search quotes in this book", text: $searchText)
                                .font(.system(size: 16, design: .serif))
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Quotes List
                    if filteredQuotes.isEmpty {
                        EmptyBookQuotesView(hasSearchText: !searchText.isEmpty)
                            .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredQuotes) { quote in
                                Button {
                                    selectedQuote = quote
                                } label: {
                                    BookQuoteCard(
                                        quote: quote,
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
                        .padding(.bottom, 100)
                    }
                }
                .padding(.top, 20)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Book Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showingAddQuote) {
            AddQuoteView(book: book)
        }
        .sheet(item: $selectedQuote) { quote in
            QuoteDetailView(quote: quote, book: book)
        }
        .onAppear {
            UINavigationBar.appearance().titleTextAttributes = [
                .font: UIFont(name: "Georgia", size: 17)!
            ]
        }
    }
}

struct BookQuoteCard: View {
    let quote: Quote
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
                // Page/Chapter Info
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
            let book = DataManager().getBook(by: quote.bookID)
            let textToShare = """
            "\(quote.content)"
            
            — \(book?.author ?? "Unknown"), \(book?.title ?? "Unknown")\(pageText)
            """
            
            ShareSheet(activityItems: [textToShare])
        }
    }
}

struct EmptyBookQuotesView: View {
    let hasSearchText: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: hasSearchText ? "magnifyingglass" : "quote.bubble")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "8B7355").opacity(0.5))
                .symbolRenderingMode(.hierarchical)
            
            Text(hasSearchText ? "No matching quotes" : "No quotes yet")
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundColor(.primary)
            
            Text(hasSearchText ? "Try a different search term" : "Tap the button above to add your first quote")
                .font(.system(size: 16, design: .serif))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
} 