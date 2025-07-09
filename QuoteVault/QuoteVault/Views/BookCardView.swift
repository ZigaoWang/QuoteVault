import SwiftUI

struct BookCardView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading) {
            if let coverData = book.coverImage, let uiImage = UIImage(data: coverData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 4)
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color(red: 0.95, green: 0.95, blue: 0.97))
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Text(String(book.title.prefix(1)))
                        .font(.system(size: 70, weight: .bold, design: .serif))
                        .foregroundColor(.gray.opacity(0.8))
                }
                .shadow(radius: 2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(book.author)
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.top, 8)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
} 