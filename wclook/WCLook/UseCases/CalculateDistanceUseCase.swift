//
//  CalculateDistanceUseCase.swift
//  WCLook
//
//  Created by Michel Tan on 15/11/2024.
//

import Foundation
import Combine

class CalculateDistanceUseCase {
    
    private let locationService : LocationService
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    func executeCombine(toilets : [Toilet]) -> AnyPublisher < [Toilet], Error> {
        return Future {
            promise in
         
            guard let userLocation = self.locationService.getCurrentLocation() else {
                promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get user location"])))
                return
            }
            //pour tous les toilets , il faut recuperer la location et comparer avec le userLocation.
            //mais avant , il faut creer un tableau d'association "tuple" qui sera le resultat (liste des toilets et la distance associé
            
            let toiletMap = toilets.map { toilet -> (Toilet, Double) in
                
                let distance = self.locationService.calculDistance(from: userLocation, to: toilet.location)
        
                var updateToilet = toilet
                updateToilet.distance = distance
                if(toilet.location.latitude == 0 || toilet.location.latitude == 0) {
                    updateToilet.distance = 0
                }
                return (updateToilet,distance)
            }
                                                
            //trier le tableau.
            let sortToilets = toiletMap.sorted { $0.1 < $1.1 }.map { $0.0 }
            
            promise(.success(sortToilets))
        }
        .eraseToAnyPublisher() // Masquer le type concret avec AnyPublisher
    }
    
    //retourne une closure de type Result
    func execute ( toilets : [Toilet] , completion : @escaping (Result<[Toilet],Error>) -> Void) {
        //Objectif : avoir des toilets triés.
         //recuperer la location de l'user.
        guard let userLocation = self.locationService.getCurrentLocation() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get user location"])))
            return
        }
        //pour tous les toilets , il faut recuperer la location et comparer avec le userLocation.
        //mais avant , il faut creer un tableau d'association "tuple" qui sera le resultat (liste des toilets et la distance associé
        
        let toiletMap = toilets.map { toilet -> (Toilet, Double) in
            
            let distance = self.locationService.calculDistance(from: userLocation, to: toilet.location)
    
            var updateToilet = toilet
            updateToilet.distance = distance
            if(toilet.location.latitude == 0 || toilet.location.latitude == 0) {
                updateToilet.distance = 0
            }
            return (updateToilet,distance)
        }
                                            
        //trier le tableau.
        let sortToilets = toiletMap.sorted { $0.1 < $1.1 }.map { $0.0 }
        
        completion(.success(sortToilets))
    }
    
    
}
