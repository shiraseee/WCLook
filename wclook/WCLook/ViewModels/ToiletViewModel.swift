//
//  ToiletViewModel.swift
//  WCLook
//
//  Created by Michel Tan on 10/11/2024.
//

import Foundation
import FirebaseFirestore
import Combine

class ToiletViewModel : ObservableObject {
    
    @Published var toilets: [Toilet] = []
    @Published var errorMessage: String = ""
    @Published var sortedToilets : [Toilet] = []
    @Published var isLoading: Bool = true // Variable pour afficher le loader
    private var hasLoadedToilets: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let searchToiletsUseCase : SearchToiletsUseCase
    private let calculateDistanceUseCase : CalculateDistanceUseCase
    private let mapService : MapService
    private let locationService: LocationService
    
    // Initialisation avec l'injection du SearchToiletsUseCase , CalculateDistanceUseCase et MapService
    
    init(searchToiletsUseCase: SearchToiletsUseCase,
         calculateDistanceUseCase : CalculateDistanceUseCase,
         mapService: MapService,
         locationService: LocationService) {
        self.searchToiletsUseCase = searchToiletsUseCase
        self.calculateDistanceUseCase = calculateDistanceUseCase
        self.mapService = mapService
        self.locationService = locationService
        
    }
    
    func getLocationService() -> LocationService {
        return locationService
    }
    
    func fetchToiletWithCombine(forceToRefresh: Bool = false) {
        
        guard !hasLoadedToilets || forceToRefresh else { // Condition modifiée
            if forceToRefresh {
                print("Rafraîchissement forcé des toilettes.")
            } else {
                print("Toilettes déjà chargées, pas de nouvel appel réseau (sauf si forceRefresh est true).")
            }
            return
        }
        self.isLoading = true
        
        searchToiletsUseCase.executeWithCombine()
            .mapError { error in
                // Assurez-vous que l'erreur est convertie en un type générique qui sera compatible dans tout le flux
                return error as Error
            }
            .flatMap{
                toilets in
                // Une fois que les toilettes sont récupérées, on passe à l'étape suivante
                self.calculateDistanceForToiletsWithCombine(toilets)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully fetched toilets.")
                    self.hasLoadedToilets = true // Marquer comme chargé
                case .failure(let error):
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }, receiveValue: {
                sortedToilets in
                self.sortedToilets = sortedToilets
                self.toilets = sortedToilets
                self.isLoading = false // Cacher le loader une fois le traitement terminé
                
            })
            .store(in: &cancellables)
    }
    
    // Calcule la distance pour chaque toilette et trie les résultats
    private func calculateDistanceForToiletsWithCombine(_ toilets: [Toilet]) -> AnyPublisher<[Toilet], Error> {
        // Appeler le UseCase pour calculer les distances
        return calculateDistanceUseCase.executeCombine(toilets: toilets)
            .mapError { error in
                // Convertir l'erreur en un type compatible avec le flux
                return error as Error
            }
            .eraseToAnyPublisher()
    }
    
    // Fonction pour appeler le Use Case et récupérer les toilettes
    func fetchToilet() {
        self.isLoading = true // Afficher le loader pendant la récupération des données
                
        searchToiletsUseCase.execute { result in
            
            switch result {
            case .success(let toilets):
                // Met à jour les toilettes et rafraîchit la vue
                DispatchQueue.main.async {
                    self.calculateDistanceForToilets(toilets)
                }
            case .failure(let error):
                // Affiche le message d'erreur si nécessaire
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    //trie les toiletes en argument les toilettes.
    private func calculateDistanceForToilets(_ toilets: [Toilet]) {
        
        self.calculateDistanceUseCase.execute(toilets: toilets) { result in
            
            switch result {
                
            case .success(let sortedToilets):
                DispatchQueue.main.async {
                    self.toilets = sortedToilets
                    self.isLoading = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur lors du calcul des distances: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    //getCurrentLocation
    func getCurrentLocation() ->UserLocation?{
        return locationService.getCurrentLocation()
    }
    
    //method URLScheme Plan et Google maps.
    func openMapsForDirections(to location: GeoPoint) {
        mapService.openMapsForDirections(to: location)
    }
    
    func openGoogleMapsForDirections(to location: GeoPoint) {
        mapService.openGoogleMapsForDirections(to: location)
    }
}
