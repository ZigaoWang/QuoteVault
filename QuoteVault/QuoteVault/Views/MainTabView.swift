import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            BooksView()
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Library")
                        .font(.system(size: 10, design: .serif))
                }
            
            QuotesView()
                .tabItem {
                    Image(systemName: "text.quote")
                    Text("Quotes")
                        .font(.system(size: 10, design: .serif))
                }
            
            DailyQuoteView()
                .tabItem {
                    Image(systemName: "sun.max")
                    Text("Daily")
                        .font(.system(size: 10, design: .serif))
                }
        }
        .accentColor(.brown.opacity(0.8))
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
} 