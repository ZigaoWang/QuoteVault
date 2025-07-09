import SwiftUI

struct BooksView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var showingAddBook = false
    @State private var searchText = ""
    
    private var filteredBooks: [Book] {
        if searchText.isEmpty {
            return dataManager.books
        } else {
            return dataManager.books.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with subtle texture
                Color(red: 0.98, green: 0.97, blue: 0.95)
                    .ignoresSafeArea()
                
                // Content
                VStack {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search books", text: $searchText)
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
                    
                    if filteredBooks.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(systemName: "books.vertical")
                                .font(.system(size: 70))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text(searchText.isEmpty ? "No books yet" : "No matching books")
                                .font(.system(size: 20, weight: .medium, design: .serif))
                                .foregroundColor(.secondary)
                            
                            Button {
                                showingAddBook = true
                            } label: {
                                Label("Add your first book", systemImage: "plus.circle.fill")
                                    .font(.system(size: 18, design: .serif))
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                                ForEach(filteredBooks) { book in
                                    NavigationLink(destination: BookDetailView(book: book)) {
                                        BookCardView(book: book)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Your Books")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddBook = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBook) {
                AddBookView()
            }
        }
    }
} 