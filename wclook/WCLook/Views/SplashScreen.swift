//
//  SplashScreen.swift
//  WCLook
//
//  Created by Michel Tan on 21/11/2024.
//

import Foundation
import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    
    var body: some View {
            
        if isActive {
            MainView()
        } else {
         
            VStack {
                
                Image("pandawclook")
                    .resizable()
                    .scaledToFit()
                    .frame(width:200, height: 200)
                    .padding()
                Text(String(localized: "title_splashscreen"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
            }
            .onAppear {
                // Délai de 2 secondes avant de passer à la vue suivante
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
