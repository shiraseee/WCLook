//
//  LocationService.swift
//  WCLook
//
//  Created by Michel Tan on 15/11/2024.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import Combine

protocol LocationService {
    func getCurrentLocation() -> UserLocation?
    func calculDistance(from userLocation: UserLocation,to toiletteLocation: GeoPoint) -> Double
    func isLocationAuthorized() -> Bool
    var locationAuthorizationPublisher: PassthroughSubject<Bool, Never> {get}// Publisher pour la localisation
}

class LocationServiceImpl : NSObject, LocationService, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    var locationAuthorizationPublisher = PassthroughSubject<Bool, Never>()
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Demander l'autorisation d'accès à la localisation
        locationManager.startUpdatingLocation() // Commencer à recevoir les mises à jour de la localisation
    }
    
    func getCurrentLocation() -> UserLocation? {
        
        guard let location = locationManager.location else {
            return nil
        }
        
        let geoPoint = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        return UserLocation(location: geoPoint)
    }
    
    func calculDistance(from userLocation: UserLocation, to toiletLocation: GeoPoint) -> Double {
        
        let coordinateLatUser = userLocation.location.latitude
        let coordinateLongAUser = userLocation.location.longitude
        
        let coordinateLatToilet = toiletLocation.latitude
        let coordinateLongToilet = toiletLocation.longitude
        
        let userCLLocation = CLLocation(latitude: coordinateLatUser, longitude: coordinateLongAUser)
        let toiletCLLocation = CLLocation(latitude: coordinateLatToilet, longitude: coordinateLongToilet)
        
        return userCLLocation.distance(from: toiletCLLocation)
    }
    
    //delegate
    // Gérer les autorisations de localisation
      func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
          switch status {
          case .authorizedWhenInUse, .authorizedAlways:
              print("Localisation autorisée")
              locationAuthorizationPublisher.send(true)  // Autorisation accordée
          case .denied, .restricted:
              print("L'utilisateur a refusé l'accès à la localisation")
              locationAuthorizationPublisher.send(false)  // Autorisation refusée
          case .notDetermined:
              locationManager.requestWhenInUseAuthorization()
          @unknown default:
              locationAuthorizationPublisher.send(false)  // Autorisation refusée
              break
          }
      }
    
    func isLocationAuthorized() -> Bool {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .authorizedWhenInUse,.authorizedAlways:
            return true
        case .denied,.restricted,.notDetermined:
            return false
        @unknown default:
            return false
        }
    }
}
