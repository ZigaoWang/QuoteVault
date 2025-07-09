import SwiftUI

struct MainTabView: View {
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        TabView {
            BooksView()
                .tabItem {
                    Label("Library", systemImage: "book")
                }
            
            QuotesView()
                .tabItem {
                    Label("Quotes", systemImage: "text.quote")
                }
            
            DailyQuoteView()
                .tabItem {
                    Label("Daily", systemImage: "sparkles")
                }
        }
        .environmentObject(dataManager)
        .tint(Color(red: 0.4, green: 0.2, blue: 0.1))
    }
} 