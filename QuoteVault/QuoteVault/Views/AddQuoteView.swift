import SwiftUI

struct AddQuoteView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    
    let book: Book
    
    @State private var quoteContent = ""
    @State private var notes: String = ""
    @State private var page: String = ""
    @State private var chapter: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Quote") {
                    TextEditor(text: $quoteContent)
                        .font(.system(size: 16, design: .serif))
                        .frame(minHeight: 150)
                }
                
                Section("Your Notes (Optional)") {
                    TextEditor(text: $notes)
                        .font(.system(size: 16, design: .serif))
                        .frame(minHeight: 80)
                        .placeholder(when: notes.isEmpty) {
                            Text("Add your thoughts about this quote...")
                                .font(.system(size: 16, design: .serif))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                }
                
                Section("Details") {
                    TextField("Page (optional)", text: $page)
                        .font(.system(size: 16, design: .serif))
                        .keyboardType(.numberPad)
                    
                    TextField("Chapter (optional)", text: $chapter)
                        .font(.system(size: 16, design: .serif))
                }
                
                Section("From") {
                    HStack {
                        Text(book.title)
                            .font(.system(size: 16, weight: .medium, design: .serif))
                        
                        Spacer()
                        
                        Text("by \(book.author)")
                            .font(.system(size: 14, design: .serif))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Quote")
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
                        saveQuote()
                    }
                    .disabled(quoteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            UINavigationBar.appearance().titleTextAttributes = [
                .font: UIFont(name: "Georgia", size: 17)!
            ]
        }
    }
    
    private func saveQuote() {
        let pageNumber = Int(page)
        
        let quote = Quote(
            content: quoteContent.trimmingCharacters(in: .whitespacesAndNewlines),
            bookID: book.id,
            page: pageNumber,
            chapter: chapter.isEmpty ? nil : chapter,
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        dataManager.addQuote(quote)
        dismiss()
    }
}

// Placeholder modifier
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
} 