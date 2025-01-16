//
//  SearchToiletsUseCase.swift
//  WCLook
//
//  Created by Michel Tan on 10/11/2024.
//

import Foundation
import Combine

class SearchToiletsUseCase {
    
    private let toiletRepository : ToiletRepository
    //private let locationService : LocationService
    
    init(toiletRepository : ToiletRepository) {
        self.toiletRepository = toiletRepository
    }
    
    //fonction pour recuperer toutes les toilettes , avec ou sans filtre (@TODO)
    func execute(completion:@escaping (Result<[Toilet],ToiletRepository.ToiletRepositoryError>) -> Void){
        toiletRepository.fetchAllToiletsWithMessage { result in
            
            switch result {
            case .success(let toilets):
                completion(.success(toilets))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func executeWithCombine() -> AnyPublisher <[Toilet],ToiletRepository.ToiletRepositoryError> {
        return toiletRepository.fetchAllToilets()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
