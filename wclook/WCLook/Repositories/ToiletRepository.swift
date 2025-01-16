//
//  ToiletRepository.swift
//  WCLook
//
//  Created by Michel Tan on 10/11/2024.
//

import Foundation
import FirebaseFirestore
import Combine


class ToiletRepository {
    
    enum ToiletRepositoryError: Error {
        case networkError(String)
        case dataError(String)
        case unknownError(String)
    }
    
    private let db = Firestore.firestore()
        
    // Fetch all toilets using Combine for reactive handling
    func fetchAllToilets() -> AnyPublisher<[Toilet], ToiletRepositoryError> {
        return Future { promise in
            self.db.collection("toilets").getDocuments { (querySnapshot, error) in
                // Handle network error
                if let error = error {
                    promise(.failure(.networkError("Erreur de connexion réseau.")))
                    return
                }
                
                // Ensure querySnapshot is not nil
                guard let snapshot = querySnapshot else {
                    promise(.failure(.dataError("Erreur lors de la récupération des données (snapshot manquant).")))
                    return
                }
                
                var toilets: [Toilet] = []
                
                // Iterate through documents and parse data
                for document in snapshot.documents {
                    let data = document.data()
                    let id = document.documentID
                    let name = data["name"] as? String ?? "Nom non disponible"
                    let location = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
                    let address = data["adress"] as? String ?? "Adresse non disponible"
                    let isAccessible = data["isAccessible"] as? Bool ?? false
                    let cleanliness = ToiletCleanliness(rawValue: data["cleanliness"] as? String ?? "") ?? .average
                    let isOpen = data["isOpen"] as? Bool ?? true
                    let note = data["note"] as? String ?? ""
                    let quality = data["quality"] as? Int ?? 0
                    let animalImage = data["image"] as? String ?? "toilet"
                    
                    let openingHoursData = data["openingHours"] as? [String: String] ?? [:]
                    let openingHours = OpeningHours(
                        monday: openingHoursData["monday"] ?? "",
                        tuesday: openingHoursData["tuesday"] ?? "",
                        wednesday: openingHoursData["wednesday"] ?? "",
                        thursday: openingHoursData["thursday"] ?? "",
                        friday: openingHoursData["friday"] ?? "",
                        saturday: openingHoursData["saturday"] ?? "",
                        sunday: openingHoursData["sunday"] ?? ""
                    )
                    
                    var reviews: [Review] = []
                    if let reviewsData = data["reviews"] as? [[String: Any]] {
                        for reviewData in reviewsData {
                            if let id = reviewData["id"] as? String,
                               let userId = reviewData["userId"] as? String,
                               let rating = reviewData["rating"] as? Int,
                               let comment = reviewData["comment"] as? String,
                               let date = reviewData["date"] as? Timestamp {
                                let review = Review(id: id, userId: userId, rating: rating, coment: comment, date: date.dateValue())
                                reviews.append(review)
                            }
                        }
                    }
                    
                    let toilet = Toilet(
                        id: id,
                        name: name,
                        location: location,
                        address: address,
                        isAccessible: isAccessible,
                        cleanliness: cleanliness,
                        isOpen: isOpen,
                        openingHours: openingHours,
                        reviews: reviews,
                        note: note,
                        quality: quality,
                        animalImage: animalImage
                    )
                    
                    toilets.append(toilet)
                }
                
                if toilets.isEmpty {
                    promise(.failure(.dataError(String(localized: "no_toilets_found"))))
                } else {
                    promise(.success(toilets))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    

    func fetchAllToiletsWithMessage(completion: @escaping (Result<[Toilet], ToiletRepositoryError>) -> Void) {
        db.collection("toilets").getDocuments { (querySnapshot, error) in
            
            // Gérer l'erreur réseau de manière plus robuste
            if let error = error {
                print("Erreur lors de la récupération des toilettes : \(error.localizedDescription)")
                completion(.failure(.networkError("Erreur de connexion réseau.")))
                return
            }
            
            // Vérifier si querySnapshot est nil avant de l'utiliser
            guard let snapshot = querySnapshot else {
                completion(.failure(.dataError("Erreur lors de la récupération des données (snapshot manquant).")))
                return
            }

            var toilets: [Toilet] = []
            
            // Itérer sur chaque document dans la collection
            for document in snapshot.documents {
                // Extraire les données du document
                let data = document.data()
                
                // Extraction des données et création des objets correspondants
                let id = document.documentID
                let name = data["name"] as? String ?? "Nom non disponible"
                let location = data["location"] as? GeoPoint ?? GeoPoint(latitude: 0.0, longitude: 0.0)
                let address = data["adress"] as? String ?? "Adresse non disponible"
                let isAccessible = data["isAccessible"] as? Bool ?? false
                let cleanliness = ToiletCleanliness(rawValue: data["cleanliness"] as? String ?? "") ?? .average
                let isOpen = data["isOpen"] as? Bool ?? true
                let note = data["note"] as? String ?? ""
                let quality = data["quality"] as? Int ?? 0
                let animalImage = data["image"] as? String ?? "toilet"
                
                // Extraire les horaires d'ouverture
                let openingHoursData = data["openingHours"] as? [String: String] ?? [:]
                let openingHours = OpeningHours(
                    monday: openingHoursData["monday"] ?? "",
                    tuesday: openingHoursData["tuesday"] ?? "",
                    wednesday: openingHoursData["wednesday"] ?? "",
                    thursday: openingHoursData["thursday"] ?? "",
                    friday: openingHoursData["friday"] ?? "",
                    saturday: openingHoursData["saturday"] ?? "",
                    sunday: openingHoursData["sunday"] ?? ""
                )
                
                // Extraire les avis
                var reviews: [Review] = []
                if let reviewsData = data["reviews"] as? [[String: Any]] {
                    for reviewData in reviewsData {
                        if let id = reviewData["id"] as? String,
                           let userId = reviewData["userId"] as? String,
                           let rating = reviewData["rating"] as? Int,
                           let comment = reviewData["comment"] as? String,
                           let date = reviewData["date"] as? Timestamp {
                            let review = Review(id: id, userId: userId, rating: rating, coment: comment, date: date.dateValue())
                            reviews.append(review)
                        }
                    }
                }
                
                // Créer un objet Toilet
                let toilet = Toilet(
                    id: id,
                    name: name,
                    location: location,
                    address: address,
                    isAccessible: isAccessible,
                    cleanliness: cleanliness,
                    isOpen: isOpen,
                    openingHours: openingHours,
                    reviews: reviews,
                    note: note,
                    quality: quality,
                    animalImage: animalImage
                )
                
                toilets.append(toilet)
            }
            
            // Si aucune toilette n'est trouvée
            if toilets.isEmpty {
                completion(.failure(.dataError(String(localized: "no_toilets_found"))))
            } else {
                completion(.success(toilets))
            }
        }
    }

}
