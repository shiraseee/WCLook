//
//  MapService.swift
//  WCLook
//
//  Created by Michel Tan on 17/11/2024.
//

import Foundation
import FirebaseFirestore

class MapService {
    
    func openMapsForDirections(to location: GeoPoint) {
        
        let latitude = location.latitude
        let longitude = location.longitude
        let urlString = "maps://?daddr=\(latitude),\(longitude)"
        //maps://?daddr=\(latitude),\(longitude)

        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }else {
            print("unable to open Apple Maps")
        }
    }
    
    // Fonction pour ouvrir l'itinéraire dans Google Maps
      func openGoogleMapsForDirections(to location: GeoPoint) {
          let latitude = location.latitude
          let longitude = location.longitude
          let urlString = "comgooglemaps://?daddr=\(latitude),\(longitude)"
          
          if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
              // Ouvre Google Maps si l'application est installée
              UIApplication.shared.open(url, options: [:]) { success in
                  if !success {
                      // Si Google Maps n'est pas installé ou ne s'ouvre pas, ouvrir la version web de Google Maps
                      self.openGoogleMapsWeb(latitude: latitude, longitude: longitude)
                  }
              }
          } else {
              // Si Google Maps n'est pas installé, ouvrir la version web
              self.openGoogleMapsWeb(latitude: latitude, longitude: longitude)
          }
      }
      
      // Fonction pour ouvrir Google Maps en version web
      private func openGoogleMapsWeb(latitude: Double, longitude: Double) {
          let webUrl = "https://www.google.com/maps/dir/?daddr=\(latitude),\(longitude)"
          if let url = URL(string: webUrl) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
      }
}
