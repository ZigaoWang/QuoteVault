import SwiftUI

struct QuoteCardView: View {
    let quote: Quote
    let book: Book?
    var onFavoriteToggle: () -> Void
    @State private var showingShare = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Quote content
            Text("""
                \(quote.content)
                """)
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundColor(.primary)
                .lineSpacing(8)
                .padding(.horizontal, 8)
            
            // Notes if available
            if let notes = quote.notes {
                Text(notes)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .italic()
            }
            
            Divider()
                .padding(.horizontal)
            
            // Book info and action buttons
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(book?.title ?? "Unknown Book")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        if let page = quote.page {
                            Label("Page \(page)", systemImage: "book")
                                .font(.system(size: 12, design: .serif))
                                .foregroundColor(.secondary)
                        }
                        
                        if let chapter = quote.chapter, !chapter.isEmpty {
                            Label(chapter, systemImage: "bookmark")
                                .font(.system(size: 12, design: .serif))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: onFavoriteToggle) {
                        Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(quote.isFavorite ? .red : .gray)
                            .font(.system(size: 18))
                    }
                    
                    Button {
                        showingShare = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        .sheet(isPresented: $showingShare) {
            if let book = book {
                let pageText = quote.page != nil ? " (Page \(quote.page!))" : ""
                let textToShare = """
                "\(quote.content)"
                
                — \(book.author), \(book.title)\(pageText)
                """
                
                ShareSheet(activityItems: [textToShare])
            }
        }
    }
} 