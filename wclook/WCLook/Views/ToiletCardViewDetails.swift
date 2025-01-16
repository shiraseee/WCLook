//
//  ToiletCardViewDetails.swift
//  WCLook
//
//  Created by Michel Tan on 21/11/2024.
//

import Foundation
import SwiftUI
import _MapKit_SwiftUI
import FirebaseFirestore

import SwiftUI
import MapKit

struct ToiletCardViewDetails: View {

    @State var toilet: Toilet
    @ObservedObject var viewModel: ToiletViewModel

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), // Valeur par défaut (Paris)
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var isInitialized = false // Pour contrôler l'initialisation
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Section principale
                VStack(alignment: .leading, spacing: 8) {
                    Text(toilet.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(toilet.address)
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                    
                    // Bouton pour copier l’adresse
                    Button(action: {
                        UIPasteboard.general.string = toilet.address
                    }) {
                        Label(String(localized: "copy_address"), systemImage: "doc.on.clipboard")
                            .font(.callout)
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Capsule().fill(Color.blue.opacity(0.1)))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Section de la carte et de la navigation
                GroupBox {
                    VStack(alignment: .leading, spacing: 16) {
                        // Affichage de la carte
                        ToiletMapView(toilet: toilet, viewModel: viewModel)
                            .frame(height: 250)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "figure.walk")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.primary)
                            
                            Text(String(localized: "text_open_maps"))
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 40) {
                            // Bouton Apple Maps
                            VStack {
                                Button(action: {
                                    viewModel.openMapsForDirections(to: toilet.location)
                                }) {
                                    Image(systemName: "map.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .padding()
                                        .background(Circle().fill(Color.blue))
                                        .foregroundColor(.white)
                                        .shadow(radius: 3)
                                }
                                Text(String(localized: "open_plans"))
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 60)
                            }
                            
                            // Bouton Google Maps
                            VStack {
                                Button(action: {
                                    viewModel.openGoogleMapsForDirections(to: toilet.location)
                                }) {
                                    Image(systemName: "globe")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .padding()
                                        .background(Circle().fill(Color.green))
                                        .foregroundColor(.white)
                                        .shadow(radius: 3)
                                }
                                Text(String(localized:"open_google_maps"))
                                    .font(.footnote)
                                    .foregroundColor(.green)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 80)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } label: {
                    Text(String(localized: "map_section_title")) // "Localisation"
                        .font(.headline)
                }
                .groupBoxStyle(TransparentGroupBoxStyle())
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
        .navigationBarTitle(String(localized: "wc_details"), displayMode: .inline)
        .onAppear {
            if !isInitialized {
                region.center = CLLocationCoordinate2D(latitude: toilet.location.latitude,
                                                       longitude: toilet.location.longitude)
                isInitialized = true
            }
        }
    }
}

// MARK: - GroupBox Style Personnalisé (Optionnel)
struct TransparentGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label
                .font(.headline)
                .padding(.horizontal, 8)
            configuration.content
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}


struct ToiletCardViewDetails_Previews : PreviewProvider {
    
    static var previews: some View {
        // Création de données fictives pour la vue
        let testToilet = Toilet(
            id: "1",
            name: "Toilette du Parc",
            location: GeoPoint(latitude: 48.8566, longitude: 2.3522),
            address: "Jardin du Luxembourg, Paris",
            distance: 1500,
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
        ToiletCardViewDetails(toilet: testToilet, viewModel: viewModel)
        
    }
}
