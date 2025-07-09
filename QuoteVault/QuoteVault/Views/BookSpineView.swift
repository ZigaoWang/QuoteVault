import SwiftUI

struct BookSpineView: View {
    let book: Book
    let height: CGFloat = 200
    
    private var spineWidth: CGFloat {
        // Vary spine width based on title length to simulate different book thicknesses
        let baseWidth: CGFloat = 35
        let titleLength = book.title.count
        return baseWidth + CGFloat(titleLength / 8) * 2
    }
    
    private var spineColor: Color {
        // Generate a color based on the book title for variety
        let hash = book.title.hashValue
        let colors: [Color] = [
            Color(red: 0.8, green: 0.3, blue: 0.3),   // Deep red
            Color(red: 0.2, green: 0.5, blue: 0.8),   // Deep blue
            Color(red: 0.3, green: 0.6, blue: 0.3),   // Deep green
            Color(red: 0.6, green: 0.4, blue: 0.8),   // Purple
            Color(red: 0.8, green: 0.5, blue: 0.2),   // Orange
            Color(red: 0.5, green: 0.3, blue: 0.2),   // Brown
            Color(red: 0.7, green: 0.2, blue: 0.5),   // Magenta
            Color(red: 0.2, green: 0.6, blue: 0.6),   // Teal
        ]
        return colors[abs(hash) % colors.count]
    }
    
    var body: some View {
        ZStack {
            // Book spine background
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: spineColor, location: 0.0),
                            .init(color: spineColor.opacity(0.8), location: 0.3),
                            .init(color: spineColor.opacity(0.9), location: 0.7),
                            .init(color: spineColor.opacity(0.7), location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: spineWidth, height: height)
            
            // Book spine shadow/depth effect
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.3),
                            Color.clear,
                            Color.black.opacity(0.1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: spineWidth, height: height)
            
            // Vertical text on spine
            VStack(spacing: 8) {
                Spacer()
                
                // Book title (rotated)
                Text(book.title)
                    .font(.system(size: 12, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .rotationEffect(.degrees(-90))
                    .frame(width: height - 40, height: 20)
                
                Spacer()
                
                // Author name (rotated)
                Text(book.author)
                    .font(.system(size: 10, weight: .medium, design: .serif))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .rotationEffect(.degrees(-90))
                    .frame(width: height - 40, height: 15)
                
                Spacer()
            }
            
            // Subtle highlight on the left edge
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 2, height: height)
                .offset(x: -spineWidth/2 + 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
    }
} 