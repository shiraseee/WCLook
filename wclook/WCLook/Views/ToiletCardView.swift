//
//  ToiletCardView.swift
//  WCLook
//
//  Created by Michel Tan on 16/11/2024.
//


import SwiftUI
import FirebaseFirestore

struct ToiletCardView: View {
    @State var toilet: Toilet
    @ObservedObject var viewModel: ToiletViewModel
    
    var body: some View {
        ZStack {
            // Carte au premier plan
            VStack {
                // 1) En-tête + Visuel principal
                headerSection
                
                // 2) Détails et informations complémentaires
                infoSection
                    .padding(.top, 6)
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - En-tête + Visuel principal
    private var headerSection: some View {
        HStack(spacing: 16) {
            // Bloc de gauche : image + distance
            VStack {
                // Image de la toilette
                Image(toilet.getNameImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .accessibilityLabel("Image représentant \(toilet.name)")
                
                // Affichage de la distance
                if let distance = toilet.distance, distance > 0 {
       
                    Text(
                        distance < 1000
                            ? "\(distance, specifier: "%.f") m"
                            : "\(distance / 1000, specifier: "%.2f") km"
                    )
                    .foregroundColor(.blue)
                    .font(.custom("AmericanTypewriter", size: 28))
                    .accessibilityLabel(
                        distance < 1000
                            ? "Distance estimée à \(distance, specifier: "%.f") m"
                            : "Distance estimée à \(distance / 1000, specifier: "%.2f") km"
                    )
                } else {
                    Text("Distance inconnue")
                        .foregroundColor(.gray)
                        .font(.custom("AmericanTypewriter", size: 16))
                        .italic()
                }
            }
            //.padding()
            Spacer()
            // Bloc de droite : Nom + Qualité (🧻) + Boutons de navigation
            VStack(alignment: .leading, spacing: 8) {
                // Nom de la toilette
                Text(toilet.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Qualité des toilettes avec icônes de papier toilette
                if toilet.quality > 0 {
                    HStack(spacing: 4) {
                        ForEach(0..<toilet.quality, id: \.self) { _ in
                            Text("🧻")
                                .font(.system(size: 22))
                        }
                    }
                }
                // Boutons de navigation (Apple/Google Maps)
                navigationButtons
            }
            //.padding()
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground).opacity(0.9))
        )
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Détails et informations complémentaires
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Adresse
            if !toilet.address.isEmpty {
                Label {
                    Text(toilet.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } icon: {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.pink)
                }
            }
            // Note
            if !toilet.note.isEmpty {
                Label {
                    Text(toilet.note)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } icon: {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                }
            }
            // Distance + Durée à pied
            if let distance = toilet.distance, distance > 0 {
                Label {
                    Text(distance < 1000 ?
                         "\(distance, specifier: "%.f") m" :
                            "\(distance / 1000, specifier: "%.2f") km")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                } icon: {
                    Image(systemName: "location.circle")
                        .foregroundColor(.blue)
                }
                
                Label {
                    Text("Durée à pied: \(toilet.durationToWalk)")
                        .font(.subheadline)
                        .foregroundColor(.green)
                } icon: {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.green)
                }
            } else {
                Label {
                    Text(String(localized: "unknown_localization"))
                        .font(.subheadline)
                        .foregroundColor(.red)
                } icon: {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground).opacity(0.9))
        )
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Boutons de navigation
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            // Apple Maps
            Button(action: {
                viewModel.openMapsForDirections(to: toilet.location)
            }) {
                VStack {
                    Image(systemName: "map.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding()
                        .background(Circle().fill(Color.blue))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                    
                    Text(String(localized: "open_plans"))
                        .font(.caption)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .frame(width: 50)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Google Maps
            Button(action: {
                viewModel.openGoogleMapsForDirections(to: toilet.location)
            }) {
                VStack {
                    Image(systemName: "globe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding()
                        .background(Circle().fill(Color.green))
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                    
                    Text(String(localized: "open_google_maps"))
                        .font(.caption)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .frame(width: 80)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 6)
    }
}

// MARK: - Preview
struct ToiletCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Création de données fictives pour la vue
        let testToilet = Toilet(
            id: "1",
            name: "Toilette du Parc",
            location: GeoPoint(latitude: 48.8566, longitude: 2.3522),
            address: "Jardin du Luxembourg, Paris",
            distance: 900,
            isAccessible: true,
            cleanliness: .clean,
            isOpen: true,
            openingHours: nil,
            reviews: [],
            note: "Très propre",
            quality: 3,// Haute qualité pour l'exemple
            animalImage: "lion"
        )
        let toiletRepository = ToiletRepository()
        let searchToiletsUseCase = SearchToiletsUseCase(toiletRepository: toiletRepository)
        let locationService = LocationServiceImpl()
        let calculateDistanceUseCase = CalculateDistanceUseCase(locationService: locationService)
        let mapService = MapService()
       
        let viewModel = ToiletViewModel(searchToiletsUseCase: searchToiletsUseCase,calculateDistanceUseCase:calculateDistanceUseCase
                                        ,mapService:mapService
        ,locationService: locationService)
        
        ToiletCardView(toilet: testToilet, viewModel: viewModel)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
