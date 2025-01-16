//
//  ContentView.swift
//  WCLook
//
//  Created by Michel Tan on 10/11/2024.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel : ToiletViewModel
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var isLoading : Bool = true // variable pour gerer l'affichage
    @State private var locationAuthorized: Bool = false // Indicateur de l'autorisation de localisation
    @State private var cancellables: Set<AnyCancellable> = []
       
    init() {
        let toiletRepository = ToiletRepository()
        let searchToiletsUseCase = SearchToiletsUseCase(toiletRepository: toiletRepository)
        let locationService = LocationServiceImpl()
        let calculateDistanceUseCase = CalculateDistanceUseCase(locationService: locationService)
        let mapService = MapService()
        
        _viewModel = StateObject(wrappedValue: ToiletViewModel(searchToiletsUseCase: searchToiletsUseCase,
            calculateDistanceUseCase: calculateDistanceUseCase,
                                                              mapService: mapService,
                                                              locationService: locationService))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .bottom) {
                    if viewModel.isLoading {
                        //affichage du loader
                        ProgressView(String(localized:"loading"))
                            .progressViewStyle(CircularProgressViewStyle(tint:.blue))
                            .padding()
                    } else {
                        if locationAuthorized {
                            // Affichage des toilettes après l'autorisation de localisation
                            if !viewModel.toilets.isEmpty {
                                List(viewModel.toilets, id: \.id) { toilet in
                                    NavigationLink(destination: ToiletCardViewDetails(toilet: toilet, viewModel: viewModel)) {
                                        ToiletCardView(toilet: toilet, viewModel: viewModel)
                                    }
                                }
                                // Ajout de la fonctionnalité Pull to Refresh
                                .refreshable {
                                    viewModel.fetchToiletWithCombine(forceToRefresh: true)  // Rafraîchissement lors du tirage
                                }
                            } else {
                                Text("\(viewModel.errorMessage)")
                                    .foregroundColor(.gray)
                            }
                        } else {
                            VStack {
                                // Affichage d'un message en attendant l'autorisation de localisation
                                Text(String(localized:"error_authorization_localization"))
                                    .foregroundColor(.red)
                                    .padding()
                                Button(action:openSettings) {
                                    Text(String(localized:"open_settings"))
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    StickyBannerView()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                }
            }
            .onAppear {
                // Charger les toilettes au démarrage de la vue
                checkLocationAuthorization()
                //isLoading = false
            }
            .navigationTitle(String(localized: "title_app"))
            .background(Color.clear) // Assurez-vous que le fond de la vue principale soit transparent
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Eviter certains comportements de style par défaut
    }
    
    // Fonction pour vérifier l'autorisation de localisation
    private func checkLocationAuthorization() {
        viewModel.getLocationService().locationAuthorizationPublisher
            .catch { _ in Just(false) } // Gérer les erreurs
            .removeDuplicates() // Important pour éviter des appels multiples si l'autorisation ne change pas réellement
            .sink { authorized in
                self.locationAuthorized = authorized // Met à jour la propriété
                if authorized {
                    self.viewModel.fetchToiletWithCombine()
                } else {
                    // Gérer le cas où l'autorisation est refusée (ex: afficher un message à l'utilisateur)
                    print("Autorisation de localisation refusée")
                    self.viewModel.errorMessage = String(localized: "location_permission_denied")
                    self.viewModel.isLoading = false // important de mettre le loading a false
                }
            }
            .store(in: &cancellables)
        
        // Gestion du cas initial (lorsque la vue apparaît)
        locationAuthorized = viewModel.getLocationService().isLocationAuthorized()
        if locationAuthorized {
            viewModel.fetchToiletWithCombine()
        } else if !locationAuthorized{
            viewModel.errorMessage = String(localized: "location_permission_denied")
            viewModel.isLoading = false
        }
    }
    
    // Fonction pour ouvrir les réglages de l'application
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
