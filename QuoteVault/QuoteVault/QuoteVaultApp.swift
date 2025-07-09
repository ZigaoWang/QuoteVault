//
//  QuoteVaultApp.swift
//  QuoteVault
//
//  Created by Zigao Wang on 7/9/25.
//

import SwiftUI

@main
struct QuoteVaultApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(dataManager)
        }
    }
}
