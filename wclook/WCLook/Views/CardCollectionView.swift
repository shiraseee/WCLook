//
//  Untitled.swift
//  WCLook
//
//  Created by Michel Tan on 15/12/2024.
//

import SwiftUI

struct CardCollectionView: View {
    // Une liste d'images ou d'éléments à afficher
    let images = ["elephant", "girafle", "lion", "panda", "zebre"]

    // Configuration du LazyVGrid
    let columns = [
        GridItem(.flexible()), // Première colonne
        GridItem(.flexible())  // Deuxième colonne
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(images, id: \.self) { image in
                    Image(image) // Assurez-vous d'avoir des images dans votre asset catalog ou utilisez un nom d'image valide
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150) // Taille de chaque image
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding()
        }
    }
}

struct CardCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CardCollectionView()
    }
}
