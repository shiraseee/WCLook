import SwiftUI
import MapKit
import FirebaseFirestore

struct ToiletMapView: View {
    @State var toilet: Toilet
    @ObservedObject var viewModel: ToiletViewModel
    // Utilisation de @State pour pouvoir modifier la valeur
    @State private var isInitialized = false
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Utilisation du suivi de l'utilisateur
    @State private var userTrackingMode: MapUserTrackingMode = .follow // Nouveau suivi de l'utilisateur avec iOS 17

    var body: some View {
        ZStack {
            // Carte avec la localisation de la toilette
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: viewModel.toilets) { ltoilet in
                // Utilisation de MapAnnotation au lieu de MapPin pour gérer le tap
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: ltoilet.location.latitude, longitude: ltoilet.location.longitude)) {
                    // Lorsque l'on clique sur un pin, naviguer vers ToiletDetailView
                    NavigationLink(destination: ToiletDetailView(toilet: ltoilet, viewModel: viewModel)) {
                        if(toilet.location.latitude == ltoilet.location.latitude &&
                           toilet.location.longitude == ltoilet.location.longitude) {
                            Image(systemName: "toilet") // Icône pour la toilette
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "toilet") // Icône pour la toilette
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                        }
                        
                    }
                }
            }
            .frame(height: 250)
            .cornerRadius(10)
            .padding()
            .onAppear() {
                // Mettre à jour la région avec la position de l'utilisateur
                if !self.isInitialized {
                    /* if let userLocation = viewModel.getCurrentLocation() {
                     region.center = CLLocationCoordinate2D(latitude: userLocation.location.latitude, longitude: userLocation.location.longitude)
                     isInitialized = true // Empêcher l'initialisation multiple
                     
                     }*/
                    region.center = CLLocationCoordinate2D(latitude: toilet.location.latitude, longitude: toilet.location.longitude)
                    self.isInitialized = true // Empêcher l'initialisation multiple
                }
            }
            
            VStack {
                Spacer() //pousse vers le bas
                HStack {
                    Spacer()
                    // Bouton pour recentrer sur la position de l'utilisateur
                    Button(action: {
                        // Vérifier si la position de l'utilisateur est disponible
                        if let userLocation = viewModel.getCurrentLocation() {
                            region.center = CLLocationCoordinate2D(latitude: userLocation.location.latitude, longitude: userLocation.location.longitude)
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.blue))
                            .shadow(radius: 10)
                    }
                    .padding()
                }
            }
        }
    }
}

struct ToiletMapView_Previews : PreviewProvider {
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
        ToiletMapView(toilet: testToilet, viewModel: viewModel)
    }
}
