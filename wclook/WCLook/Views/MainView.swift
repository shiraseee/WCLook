//
//  MainView.swift
//  WCLook
//
//  Created by Michel Tan on 21/11/2024.
//

import Foundation
import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            NavigationView {
                ContentView()
            }.tabItem {
                Image(systemName: "house.fill")
                Text(String(localized: "home"))
            }
            
            NavigationView {
                CardCollectionView()
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text(String(localized: "card"))
            }
            
            
            NavigationView {
                QuoteListView()
            }
            .tabItem {
                Image(systemName:"person.fill")
                Text(String(localized: "citation"))
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
