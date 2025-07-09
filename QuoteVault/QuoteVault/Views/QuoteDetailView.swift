import SwiftUI

struct QuoteDetailView: View {
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingShare = false
    @State private var showingEdit = false
    
    let quote: Quote
    let book: Book
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.97, blue: 0.96),
                        Color(red: 0.96, green: 0.94, blue: 0.92)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Quote Content Card
                        VStack(spacing: 24) {
                            Image(systemName: "quote.opening")
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: "8B7355").opacity(0.5))
                            
                            Text(quote.content)
                                .font(.system(size: 22, weight: .regular, design: .serif))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(12)
                                .padding(.horizontal)
                            
                            Image(systemName: "quote.closing")
                                .font(.system(size: 36))
                                .foregroundColor(Color(hex: "8B7355").opacity(0.5))
                        }
                        .padding(.vertical, 32)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        )
                        .padding(.horizontal)
                        
                        // Notes Section (if available)
                        if let notes = quote.notes {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "note.text")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hex: "8B7355"))
                                    
                                    Text("Your Notes")
                                        .font(.system(size: 18, weight: .semibold, design: .serif))
                                        .foregroundColor(.primary)
                                }
                                
                                Text(notes)
                                    .font(.system(size: 16, design: .serif))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(6)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "F5F2ED"))
                            )
                            .padding(.horizontal)
                        }
                        
                        // Book Info
                        VStack(spacing: 16) {
                            if let coverData = book.coverImage, let uiImage = UIImage(data: coverData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                            }
                            
                            VStack(spacing: 8) {
                                Text(book.title)
                                    .font(.system(size: 20, weight: .semibold, design: .serif))
                                    .foregroundColor(.primary)
                                
                                Text("by \(book.author)")
                                    .font(.system(size: 16, design: .serif))
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 16) {
                                    if let page = quote.page {
                                        Label("Page \(page)", systemImage: "book.pages")
                                            .font(.system(size: 14, design: .serif))
                                            .foregroundColor(Color(hex: "8B7355"))
                                    }
                                    
                                    if let chapter = quote.chapter {
                                        Label(chapter, systemImage: "bookmark")
                                            .font(.system(size: 14, design: .serif))
                                            .foregroundColor(Color(hex: "8B7355"))
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 40)
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            ActionButton(
                                icon: quote.isFavorite ? "heart.fill" : "heart",
                                title: "Favorite",
                                color: quote.isFavorite ? .red : Color(hex: "8B7355"),
                                action: {
                                    dataManager.toggleFavorite(for: quote.id)
                                }
                            )
                            
                            ActionButton(
                                icon: "square.and.arrow.up",
                                title: "Share",
                                color: Color(hex: "8B7355"),
                                action: {
                                    showingShare = true
                                }
                            )
                            
                            ActionButton(
                                icon: "pencil",
                                title: "Edit",
                                color: Color(hex: "8B7355"),
                                action: {
                                    showingEdit = true
                                }
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 20)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showingShare) {
                let pageText = quote.page != nil ? " (Page \(quote.page!))" : ""
                let textToShare = """
                "\(quote.content)"
                
                — \(book.author), \(book.title)\(pageText)
                """
                
                ShareSheet(activityItems: [textToShare])
            }
        }
        .onAppear {
            UINavigationBar.appearance().titleTextAttributes = [
                .font: UIFont(name: "Georgia", size: 17)!
            ]
        }
    }
}

struct ActionButton: View {
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
                
                Text(title)
                    .font(.system(size: 14, design: .serif))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
} 