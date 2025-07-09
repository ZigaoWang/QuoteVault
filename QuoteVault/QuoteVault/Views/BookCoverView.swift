import SwiftUI

struct BookCoverView: View {
    let book: Book
    let height: CGFloat = 200
    
    private var bookAspectRatio: CGFloat {
        if let coverData = book.coverImage, let uiImage = UIImage(data: coverData) {
            return uiImage.size.width / uiImage.size.height
        }
        return 0.7
    }
    
    private var bookWidth: CGFloat {
        return height * bookAspectRatio
    }
    
    private let bindingWidth: CGFloat = 8
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 0.2, green: 0.15, blue: 0.1), location: 0.0),
                                .init(color: Color(red: 0.3, green: 0.25, blue: 0.2), location: 0.3),
                                .init(color: Color(red: 0.25, green: 0.2, blue: 0.15), location: 0.7),
                                .init(color: Color(red: 0.15, green: 0.1, blue: 0.05), location: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: bindingWidth, height: height)
                
                VStack(spacing: height * 0.05) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: bindingWidth * 0.6, height: 1)
                    }
                }
                
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
                    .frame(width: 1, height: height)
                    .offset(x: -bindingWidth/2 + 0.5)
            }
            .cornerRadius(2, corners: [.topLeft, .bottomLeft])
            
            ZStack {
                if let coverData = book.coverImage, let uiImage = UIImage(data: coverData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: bookWidth, height: height)
                        .clipped()
                } else {
                    ZStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hue: Double(book.title.hashValue % 360) / 360.0, saturation: 0.7, brightness: 0.9),
                                        Color(hue: Double(book.title.hashValue % 360) / 360.0, saturation: 0.9, brightness: 0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: bookWidth, height: height)
                        
                        VStack(spacing: 12) {
                            Spacer()
                            
                            Text(book.title)
                                .font(.system(size: min(bookWidth * 0.12, 18), weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(4)
                                .shadow(color: .black.opacity(0.5), radius: 1)
                                .padding(.horizontal, 12)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: bookWidth * 0.6, height: 1)
                            
                            Text(book.author)
                                .font(.system(size: min(bookWidth * 0.08, 14), weight: .medium, design: .serif))
                                .foregroundColor(.white.opacity(0.95))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .shadow(color: .black.opacity(0.5), radius: 1)
                                .padding(.horizontal, 12)
                            
                            Spacer()
                        }
                    }
                }
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.15),
                                Color.clear,
                                Color.clear,
                                Color.black.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: bookWidth, height: height)
            }
            .frame(width: bookWidth, height: height)
            .cornerRadius(2, corners: [.topRight, .bottomRight])
        }
        .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 3)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
} 