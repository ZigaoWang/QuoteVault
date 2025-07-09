import SwiftUI

struct QuotesView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var searchText = ""
    @State private var showingFavoritesOnly = false
    
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
                Color(red: 0.98, green: 0.97, blue: 0.95)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search quotes", text: $searchText)
                            .font(.system(size: 16, design: .serif))
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Toggle(isOn: $showingFavoritesOnly) {
                        Label("Favorites Only", systemImage: "heart.fill")
                            .font(.system(size: 16, design: .serif))
                    }
                    .padding(.horizontal)
                    .toggleStyle(SwitchToggleStyle(tint: .red))
                    
                    if filteredQuotes.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(systemName: "text.quote")
                                .font(.system(size: 70))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text(showingFavoritesOnly ? "No favorite quotes yet" : "No quotes found")
                                .font(.system(size: 20, weight: .medium, design: .serif))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredQuotes) { quote in
                                    QuoteCardView(
                                        quote: quote,
                                        book: dataManager.getBook(by: quote.bookID),
                                        onFavoriteToggle: {
                                            dataManager.toggleFavorite(for: quote.id)
                                        }
                                    )
                                }
                            }
                            .padding(.vertical)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Quotes")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
} 