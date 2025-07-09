import SwiftUI

struct DailyQuoteView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var dailyQuote: Quote?
    @State private var book: Book?
    @State private var showingShare = false
    @State private var showingQuoteDetail = false
    @State private var rotation: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    colors: [
                        Color(hex: "F5E6D3"),
                        Color(hex: "E8D5C4"),
                        Color(hex: "DCC9BA")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .hueRotation(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
                        rotation = 30
                    }
                }
                
                if let quote = dailyQuote, let book = book {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Date Header
                            VStack(spacing: 8) {
                                Text(Date().formatted(.dateTime.weekday(.wide)))
                                    .font(.system(size: 18, design: .serif))
                                    .foregroundColor(.secondary)
                                
                                Text(Date().formatted(.dateTime.day().month(.wide)))
                                    .font(.system(size: 24, weight: .semibold, design: .serif))
                                    .foregroundColor(.primary)
                            }
                            .padding(.top, 20)
                            
                            // Main Quote Card
                            VStack(spacing: 32) {
                                VStack(spacing: 24) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(hex: "8B7355"))
                                        .symbolEffect(.pulse)
                                    
                                    Text(quote.content)
                                        .font(.system(size: 24, weight: .regular, design: .serif))
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(12)
                                        .padding(.horizontal)
                                    
                                    // Notes if available
                                    if let notes = quote.notes {
                                        VStack(spacing: 8) {
                                            Rectangle()
                                                .fill(Color(hex: "8B7355").opacity(0.2))
                                                .frame(width: 50, height: 1)
                                            
                                            Text(notes)
                                                .font(.system(size: 16, design: .serif))
                                                .foregroundColor(.secondary)
                                                .italic()
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                                
                                // Book Info
                                Button {
                                    showingQuoteDetail = true
                                } label: {
                                    HStack(spacing: 16) {
                                        if let coverData = book.coverImage, let uiImage = UIImage(data: coverData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 50, height: 70)
                                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                        } else {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(LinearGradient(
                                                    colors: [Color(hex: "E8DCC6"), Color(hex: "DFD3C3")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ))
                                                .frame(width: 50, height: 70)
                                                .overlay {
                                                    Text(String(book.title.prefix(1)))
                                                        .font(.system(size: 20, weight: .bold, design: .serif))
                                                        .foregroundColor(Color(hex: "8B7355"))
                                                }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(book.title)
                                                .font(.system(size: 18, weight: .medium, design: .serif))
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                            
                                            Text("by \(book.author)")
                                                .font(.system(size: 16, design: .serif))
                                                .foregroundColor(.secondary)
                                            
                                            if let page = quote.page {
                                                Text("Page \(page)")
                                                    .font(.system(size: 14, design: .serif))
                                                    .foregroundColor(Color(hex: "8B7355"))
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.8))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(32)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                            )
                            .padding(.horizontal)
                            
                            // Action Buttons
                            HStack(spacing: 16) {
                                DailyActionButton(
                                    icon: quote.isFavorite ? "heart.fill" : "heart",
                                    title: quote.isFavorite ? "Favorited" : "Favorite",
                                    color: quote.isFavorite ? .red : Color(hex: "8B7355"),
                                    action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            dataManager.toggleFavorite(for: quote.id)
                                            if let id = dailyQuote?.id,
                                               let index = dataManager.quotes.firstIndex(where: { $0.id == id }) {
                                                dailyQuote = dataManager.quotes[index]
                                            }
                                        }
                                    }
                                )
                                
                                DailyActionButton(
                                    icon: "square.and.arrow.up",
                                    title: "Share",
                                    color: Color(hex: "8B7355"),
                                    action: {
                                        showingShare = true
                                    }
                                )
                                
                                DailyActionButton(
                                    icon: "arrow.triangle.2.circlepath",
                                    title: "New Quote",
                                    color: Color(hex: "8B7355"),
                                    action: {
                                        withAnimation(.spring(response: 0.4)) {
                                            selectRandomQuote()
                                        }
                                    }
                                )
                            }
                            .padding(.horizontal)
                            
                            Spacer(minLength: 80)
                        }
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
                    .sheet(isPresented: $showingQuoteDetail) {
                        QuoteDetailView(quote: quote, book: book)
                    }
                } else {
                    EmptyDailyView()
                }
            }
            .navigationTitle("Daily")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                selectRandomQuote()
                UINavigationBar.appearance().largeTitleTextAttributes = [
                    .font: UIFont(name: "Georgia-Bold", size: 34)!
                ]
                UINavigationBar.appearance().titleTextAttributes = [
                    .font: UIFont(name: "Georgia", size: 17)!
                ]
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

struct DailyActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .symbolRenderingMode(.hierarchical)
                
                Text(title)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
        }
    }
}

struct EmptyDailyView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "books.vertical")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "8B7355").opacity(0.5))
                .symbolRenderingMode(.hierarchical)
            
            Text("No quotes available")
                .font(.system(size: 24, weight: .medium, design: .serif))
                .foregroundColor(.primary)
            
            Text("Add some books and quotes to see your daily inspiration")
                .font(.system(size: 16, design: .serif))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
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