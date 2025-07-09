import SwiftUI
import PhotosUI

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    
    @State private var title = ""
    @State private var author = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var coverImage: UIImage?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Book Details") {
                    TextField("Title", text: $title)
                        .font(.system(size: 16, design: .serif))
                    
                    TextField("Author", text: $author)
                        .font(.system(size: 16, design: .serif))
                }
                
                Section("Cover Image") {
                    HStack {
                        Spacer()
                        
                        if let coverImage {
                            Image(uiImage: coverImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(8)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .frame(maxWidth: 140)
                                .overlay {
                                    Image(systemName: "book.closed")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                }
                        }
                        
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical)
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("Select Cover Image", systemImage: "photo")
                            .font(.system(size: 16, design: .serif))
                    }
                    .onChange(of: selectedItem) {
                        Task {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                coverImage = image
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBook()
                    }
                    .disabled(title.isEmpty || author.isEmpty)
                }
            }
        }
    }
    
    private func saveBook() {
        var imageData: Data?
        if let coverImage {
            imageData = coverImage.jpegData(compressionQuality: 0.7)
        }
        
        let book = Book(title: title, author: author, coverImage: imageData)
        dataManager.addBook(book)
        dismiss()
    }
} 