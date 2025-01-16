//
//  ToiletDetailView.swift
//  WCLook
//
//  Created by Michel Tan on 22/11/2024.
//

import Foundation
import SwiftUI
import FirebaseFirestore


struct ToiletDetailView: View {
    let toilet: Toilet
    let viewModel: ToiletViewModel
    
    var body: some View {
        ZStack {
            // (Optionnel) Image de fond pour un rendu plus agréable
            /*Image("toilet_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)*/
            
            // "Carte" au premier plan
            VStack(spacing: 16) {
                
                // Titre et adresse
                VStack(spacing: 4) {
                    Text(toilet.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if !toilet.address.isEmpty {
                        Label {
                            Text(toilet.address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.pink)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                // Bloc Distance + Durée
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        // Distance
                        if let distance = toilet.distance, distance > 0 {
                            Label {
                                Text(
                                    distance < 1000
                                        ? "\(distance, specifier: "%.f") m"
                                        : "\(distance / 1000, specifier: "%.2f") km"
                                )
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            } icon: {
                                Image(systemName: "location.circle")
                                    .foregroundColor(.blue)
                            }
                            
                            // Durée à pied
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
                } label: {
                    Text("Itinéraire")
                        .font(.headline)
                }
                .groupBoxStyle(TransparentGroupBoxStyle())
                
                // Boutons de navigation
                HStack(spacing: 24) {
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
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                                .frame(width: 60)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
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
                                .font(.footnote)
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 4)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemBackground).opacity(0.9))
            )
            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
            .padding() // Marge autour de la "carte"
        }
    }
}


struct ToiletDetailView_Previews : PreviewProvider {
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
        ToiletDetailView(toilet: testToilet, viewModel: viewModel)
    }
}
