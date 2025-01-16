//
//  Toilet.swift
//  WCLook
//
//  Created by Michel Tan on 10/11/2024.
//

import Foundation
import FirebaseFirestore

enum ToiletCleanliness: String {
    case clean = "Propre"
    case average = "Moyenne"
    case dirty = "Sale"
}

struct Review {
    let id: String
    let userId: String
    let rating : Int
    let coment: String
    let date: Date
}

struct OpeningHours {
    let monday : String
    let tuesday : String
    let wednesday : String
    let thursday : String
    let friday : String
    let saturday : String
    let sunday : String
}

struct Toilet : Identifiable{
    let id : String
    let name: String
    var location: GeoPoint
    var address: String
    var distance : Double?
    //let latitude : Double
    //let longitude : Double
    let isAccessible: Bool
    let cleanliness: ToiletCleanliness
    let isOpen: Bool
    let openingHours: OpeningHours?
    var reviews : [Review]
    var note : String
    var quality: Int // 1 à 3 pour la qualité des toilettes
    var animalImage: String// Le nom de l'image de l'animal (par exemple "lion", "elephant")
    
    // Propriété calculée pour la durée à pied
        var durationToWalk: String {
            guard let distanceInMeters = distance else {
                return "Durée inconnue"
            }
            
            // Conversion de la distance en kilomètres
            let distanceInKilometers = distanceInMeters / 1000.0
            
            // Vitesse moyenne de marche en km/h
            let walkingSpeed = 3.5 // 5 km/h
            
            // Calcul de la durée en heures (distance / vitesse)
            let durationInHours = distanceInKilometers / walkingSpeed
            
            // Conversion en minutes
            let durationInMinutes = durationInHours * 60
            
            // Calcul des heures et minutes
            let hours = Int(durationInMinutes) / 60
            let minutes = Int(durationInMinutes) % 60
            
            return "\(hours)h \(minutes)min"
        }
        
    
    // Méthode pour obtenir le nom de l'image
        func getNameImage() -> String {
            return animalImage.isEmpty ? "toilet" : animalImage
        }
    
}
