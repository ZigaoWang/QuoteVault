import SwiftUI

struct QuoteCardView: View {
    let quote: Quote
    let book: Book?
    var onFavoriteToggle: () -> Void
    
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
            
            Divider()
                .padding(.horizontal)
            
            // Book info and favorite button
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
                
                Button(action: onFavoriteToggle) {
                    Image(systemName: quote.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(quote.isFavorite ? .red : .gray)
                        .font(.system(size: 18))
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
    }
} 