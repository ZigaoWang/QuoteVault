import SwiftUI

struct DailyQuoteView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var dailyQuote: Quote?
    @State private var book: Book?
    @State private var showingShare = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.97, blue: 0.95)
                    .ignoresSafeArea()
                
                if let quote = dailyQuote, let book = book {
                    ScrollView {
                        VStack(spacing: 30) {
                            Spacer(minLength: 40)
                            
                            VStack(spacing: 20) {
                                Image(systemName: "quote.opening")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.7))
                                
                                Text(quote.content)
                                    .font(.system(size: 24, weight: .regular, design: .serif))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(10)
                                    .padding(.horizontal)
                                
                                Image(systemName: "quote.closing")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal, 20)
                            
                            VStack(spacing: 4) {
                                Text(book.title)
                                    .font(.system(size: 20, weight: .medium, design: .serif))
                                    .foregroundColor(.primary)
                                
                                Text("by \(book.author)")
                                    .font(.system(size: 18, design: .serif))
                                    .foregroundColor(.secondary)
                                
                                if let page = quote.page {
                                    Text("Page \(page)")
                                        .font(.system(size: 16, design: .serif))
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                }
                            }
                            .padding()
                            
                            HStack(spacing: 30) {
                                Button {
                                    dataManager.toggleFavorite(for: quote.id)
                                    if let id = dailyQuote?.id,
                                       let index = dataManager.quotes.firstIndex(where: { $0.id == id }) {
                                        dailyQuote = dataManager.quotes[index]
                                    }
                                } label: {
                                    VStack {
                                        Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                                            .font(.system(size: 24))
                                            .foregroundColor(quote.isFavorite ? .red : .gray)
                                        
                                        Text("Favorite")
                                            .font(.system(size: 14, design: .serif))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Button {
                                    showingShare = true
                                } label: {
                                    VStack {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 24))
                                            .foregroundColor(.blue)
                                        
                                        Text("Share")
                                            .font(.system(size: 14, design: .serif))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Button {
                                    selectRandomQuote()
                                } label: {
                                    VStack {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 24))
                                            .foregroundColor(.green)
                                        
                                        Text("New Quote")
                                            .font(.system(size: 14, design: .serif))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.top, 20)
                            
                            Spacer()
                        }
                        .padding(.bottom, 40)
                    }
                    .scrollContentBackground(.hidden)
                    .sheet(isPresented: $showingShare) {
                        let pageText = quote.page != nil ? " (Page \(quote.page!))" : ""
                        let textToShare = """
                        "\(quote.content)"
                        
                        — \(book.author), \(book.title)\(pageText)
                        """
                        
                        ShareSheet(activityItems: [textToShare])
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 70))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No quotes available")
                            .font(.system(size: 20, weight: .medium, design: .serif))
                            .foregroundColor(.secondary)
                        
                        Text("Add some books and quotes to get started")
                            .font(.system(size: 16, design: .serif))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Daily")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                selectRandomQuote()
            }
        }
    }
    
    private func selectRandomQuote() {
        guard !dataManager.quotes.isEmpty else {
            dailyQuote = nil
            book = nil
            return
        }
        
        let favoriteQuotes = dataManager.quotes.filter { $0.isFavorite }
        let quotesToChooseFrom = favoriteQuotes.isEmpty ? dataManager.quotes : favoriteQuotes
        
        if let randomQuote = quotesToChooseFrom.randomElement() {
            dailyQuote = randomQuote
            book = dataManager.getBook(by: randomQuote.bookID)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 