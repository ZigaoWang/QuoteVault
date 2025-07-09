import SwiftUI

struct BookDetailView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingAddQuote = false
    @State private var searchText = ""
    
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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Book header - full width
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        if let coverData = book.coverImage, let uiImage = UIImage(data: coverData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(radius: 4)
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                                    .frame(width: 100, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Text(String(book.title.prefix(1)))
                                    .font(.system(size: 40, weight: .bold, design: .serif))
                                    .foregroundColor(.gray.opacity(0.8))
                            }
                            .shadow(radius: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(book.title)
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundColor(.primary)
                            
                            Text("by \(book.author)")
                                .font(.system(size: 18, design: .serif))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(filteredQuotes.count) quotes")
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search quotes", text: $searchText)
                        .font(.system(size: 16, design: .serif))
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(UIColor.systemGray6))
                )
                .padding(.horizontal)
                
                // Quotes list
                if filteredQuotes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "text.quote")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text(searchText.isEmpty ? "No quotes yet" : "No matching quotes")
                            .font(.system(size: 18, design: .serif))
                            .foregroundColor(.secondary)
                        
                        Button {
                            showingAddQuote = true
                        } label: {
                            Label("Add your first quote", systemImage: "plus.circle.fill")
                                .font(.system(size: 16, design: .serif))
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredQuotes) { quote in
                            BookDetailQuoteCard(
                                quote: quote,
                                book: book,
                                onFavoriteToggle: {
                                    dataManager.toggleFavorite(for: quote.id)
                                }
                            )
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Book Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddQuote = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddQuote) {
            AddQuoteView(book: book)
        }
    }
}

struct BookDetailQuoteCard: View {
    let quote: Quote
    let book: Book
    let onFavoriteToggle: () -> Void
    @State private var showingShare = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(quote.content)
                .font(.system(size: 16, design: .serif))
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            if let notes = quote.notes {
                Text(notes)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                    .italic()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if let page = quote.page {
                        Text("Page \(page)")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(.secondary)
                    }
                    
                    if let chapter = quote.chapter {
                        Text("Chapter: \(chapter)")
                            .font(.system(size: 12, design: .serif))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button {
                        onFavoriteToggle()
                    } label: {
                        Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(quote.isFavorite ? .red : .gray)
                    }
                    
                    Button {
                        showingShare = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
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