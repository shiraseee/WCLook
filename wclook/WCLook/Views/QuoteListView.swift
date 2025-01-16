//
//  QuoteListView.swift
//  WCLook
//
//  Created by Michel Tan on 15/12/2024.
//

import SwiftUI

struct Quote: Identifiable {
    var id = UUID() // Identifiant unique pour chaque citation
    var text: String
    var author: String
}

struct QuoteListView: View {
    // Liste de citations (vous pouvez aussi les charger à partir d'une API ou d'une base de données)
    let quotes: [Quote] = [
        Quote(text: "La vie est ce qui arrive quand on est occupé à faire d'autres projets.", author: "John Lennon"),
        Quote(text: "L'avenir appartient à ceux qui croient à la beauté de leurs rêves.", author: "Eleanor Roosevelt"),
        Quote(text: "Tout ce que vous pouvez imaginer est réel.", author: "Pablo Picasso"),
        Quote(text: "La meilleure façon de prédire l'avenir est de le créer.", author: "Abraham Lincoln")
        ,
        Quote(text: "La simplicité est la sophistication suprême.", author: "Leonardo da Vinci"),
        
        Quote(text: "Tu n’apprends rien du succès , jamais. Il n’y a rien à apprendre du succès  , tu sais. Tu apprends tout de l’échec. Et la peur de l’échec est ce qui retient les gens de faire quoi que ce soit , oui . Et quand tu n’essaie pas , et tu te reveille à 65 ans. Tu es beaucoup plus en colère que si tu avais échoué . Tu sais , c’est vraiment facile d’avoir 65 ans et de dire : j’ai essayé de le faire mais je n’ai pas réussi . Tu serais vraiment furieux si tu disais : je pense que j’aurai plus le faire , mais je n’ai pas essayé.", author: "Georges Cloney"),
        
        Quote(text: "J’ai atteint un point de ma vie où les disputes ont perdu de leur charme. Je suis à la recherche de la véritable essence de la paix, choisissant de valoriser ma sérénité plutôt que l'impulsion de gagner à tout prix. J'ai appris que la tranquillité est un plus grand triomphe que n'importe quelle dispute.", author: "keanu Reeves"),
        
        Quote(text: "Le jour où vous comprendrez que lâcher prise ne signifie pas toujours perdre, que certaines batailles se gagnent en gardant votre intégrité plutôt que de recourir à la force, et qu'il y a des gens qui, peu importe les chances que vous leur donnez, ne changeront pas... ce jour-là, tu auras atteint une vraie maturité émotionnelle.", author: "Tom Hanks"),
        
        Quote(text: "Je ne sais pas si c'est de la fatigue, de la maturité ou simplement parce que je m'en soucie moins, mais certaines choses ne m'affectent plus comme avant. Ce n'est pas que j'ai perdu tout intérêt, c'est simplement que je préfère économiser mon énergie pour ce qui en vaut vraiment la peine. À ce stade, la tranquillité d'esprit a bien meilleur goût que n'importe quelle discussion gagnée.", author: "Bill Murray")
        
    ]
    
    var body: some View {
        NavigationView {
            List(quotes) { quote in
                VStack(alignment: .leading) {
                    Text(quote.text)
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    Text("- \(quote.author)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.bottom, 10)
            }
            .navigationTitle(String(localized: "title_citations"))
        }
    }
}

struct QuoteListView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteListView()
    }
}
