import SwiftUI

struct BookshelfView: View {
    let books: [Book]
    let onBookTap: (Book) -> Void
    
    private let shelfHeight: CGFloat = 240
    private let shelfSpacing: CGFloat = 50
    
    private var booksPerShelf: Int {
        if books.count <= 2 {
            return books.count
        } else if books.count <= 6 {
            return 3
        } else {
            return 4
        }
    }
    
    private var shelves: [[Book]] {
        guard !books.isEmpty else { return [] }
        
        var result: [[Book]] = []
        var currentShelf: [Book] = []
        
        for book in books {
            if currentShelf.count >= booksPerShelf {
                result.append(currentShelf)
                currentShelf = []
            }
            currentShelf.append(book)
        }
        
        if !currentShelf.isEmpty {
            result.append(currentShelf)
        }
        
        return result
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: shelfSpacing) {
                ForEach(Array(shelves.enumerated()), id: \.offset) { shelfIndex, shelfBooks in
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            if shelfBooks.count <= 2 {
                                BookendView(isLeft: true)
                            }
                            
                            ForEach(shelfBooks, id: \.id) { book in
                                Button {
                                    onBookTap(book)
                                } label: {
                                    BookCoverView(book: book)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onTapGesture {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                            }
                            
                            if shelfBooks.count <= 2 {
                                BookendView(isLeft: false)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 16)
                        
                        ZStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color(red: 0.65, green: 0.45, blue: 0.25), location: 0.0),
                                            .init(color: Color(red: 0.75, green: 0.55, blue: 0.35), location: 0.2),
                                            .init(color: Color(red: 0.7, green: 0.5, blue: 0.3), location: 0.5),
                                            .init(color: Color(red: 0.6, green: 0.4, blue: 0.2), location: 0.8),
                                            .init(color: Color(red: 0.5, green: 0.3, blue: 0.15), location: 1.0)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 20)
                            
                            VStack(spacing: 2) {
                                ForEach(0..<3) { _ in
                                    Rectangle()
                                        .fill(Color.black.opacity(0.1))
                                        .frame(height: 0.5)
                                }
                            }
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.85, green: 0.65, blue: 0.45),
                                            Color.clear
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 3)
                                .offset(y: -8.5)
                            
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.clear,
                                            Color.black.opacity(0.4)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: 6)
                                .offset(y: 10)
                        }
                        .cornerRadius(2)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 3)
                    }
                }
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 80)
            }
            .padding(.top, 40)
        }
        .background(
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
                
                Rectangle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color(red: 0.9, green: 0.85, blue: 0.8).opacity(0.3)
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 400
                        )
                    )
            }
            .ignoresSafeArea()
        )
    }
}

struct BookendView: View {
    let isLeft: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.3, green: 0.25, blue: 0.2),
                            Color(red: 0.4, green: 0.35, blue: 0.3),
                            Color(red: 0.2, green: 0.15, blue: 0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 20, height: 160)
                .cornerRadius(3)
            
            VStack(spacing: 20) {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 8, height: 8)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 12, height: 2)
                
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 8, height: 8)
            }
        }
        .shadow(color: .black.opacity(0.3), radius: 2, x: isLeft ? -1 : 1, y: 2)
    }
} 