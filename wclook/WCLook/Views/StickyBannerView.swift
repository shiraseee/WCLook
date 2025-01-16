import SwiftUI

struct StickyBannerView: View {
    @State private var isBannerVisible = true
    @State private var currentOffset: CGFloat = 100 // Initialement hors de l'écran (à droite)
    @State private var currentTextIndex = 0 // Index pour savoir quel texte afficher
    @State private var isAnimating = false // Permet de contrôler l'animation
  
    private let bannerItems = [
        "Eleanor Roosevelt: L'avenir appartient à ceux qui croient à la beauté de leurs rêves. ",
        "Leonardo da Vinci: La simplicité est la sophistication suprême.",
        "Abraham Lincoln: La meilleure façon de prédire l'avenir est de le créer."
    ]
    
    let scrollSpeed: CGFloat = 344 // Largeur complète de la bannière
    let timerInterval: Double = 5 // Intervalle de 5 secondes avant changement de texte
    let bannerWidth: CGFloat = 200 // Largeur fixe de la bannière
    let bannerHeight: CGFloat = 78 // Hauteur fixe de la bannière
    
    var body: some View {
        //   ZStack(alignment: .top) {
        if isBannerVisible {
            //HStack {
            RoundedRectangle(cornerRadius: 5) // Bord arrondi
                .fill(Color(hex: "#70E000")) // Couleur de fond de la vue
                .frame(maxWidth: .infinity) // Prend toute la largeur de l'écran
                .frame(height: 100) // Hauteur fixe de la vue
                .overlay {
                    ZStack(alignment: .trailing) {
                        // Afficher un seul texte défilant à la fois
                        Text(bannerItems[currentTextIndex])
                            //.font(.headline)
                            .font(.custom("Inter", size: 16)) // Police Inter et taille 12px
                            .foregroundColor(.white) // Texte blanc
                            .padding(.vertical, 10)
                            .padding(.horizontal, 45) // Padding horizontal pour le texte
                            .offset(y: currentOffset)
                            .clipped()
                            .onAppear {
                                if !isAnimating {
                                    startScrolling() // Démarrer l'animation seulement une fois
                                }
                            }
                        // Bouton de fermeture dans le coin supérieur droit
                        Button(action: {
                            withAnimation {
                                isBannerVisible = false
                            }
                        }) {
                            Image("buttonClose")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .padding(7.5)
                                //.padding(.horizontal, 10)
                        }
                        .padding(.horizontal,10)
                    }
                }
        }
    }
   
    // Fonction pour démarrer le défilement des textes
    private func startScrolling() {
        isAnimating = true
        
        // Faire entrer la bannière depuis la droite
        withAnimation(.easeInOut(duration: 2)) {
            currentOffset = 0 // Positionner la bannière au centre (entrée)
        }
        
        // Après 5 secondes, faire sortir la bannière vers la gauche
        DispatchQueue.main.asyncAfter(deadline: .now() + timerInterval) {
            withAnimation(.easeInOut(duration: 2)) {
                currentOffset = -bannerHeight-(bannerHeight/2) // Faire sortir la bannière vers le haut
            }
            
            // Après la sortie, passer au texte suivant
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Réinitialiser la position pour le prochain texte
                currentOffset = bannerHeight/2 // Réinitialiser la position pour le texte suivant
                currentTextIndex = (currentTextIndex + 1) % bannerItems.count
                
                // Relancer l'animation pour le texte suivant
                isAnimating = false
                startScrolling() // Démarrer à nouveau l'animation pour le texte suivant
            }
        }
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        let scanner = Scanner(string: hexSanitized)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        
        let red = Double((hexNumber & 0xFF0000) >> 16) / 255.0
        let green = Double((hexNumber & 0x00FF00) >> 8) / 255.0
        let blue = Double(hexNumber & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    StickyBannerView()
}

