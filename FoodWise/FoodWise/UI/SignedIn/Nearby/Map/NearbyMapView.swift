//
//  NearbyMapView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import SwiftUI
import MapKit

let merchants: [Merchant] = [
  .init(
    logoUrl: URL(string: "https://i.pinimg.com/736x/cf/20/ea/cf20ead30ec0a3622d6db1f6da25b16c.jpg"),
    name: "London",
    coordinate: (-8.6345300, 115.2345579)
  ),
  .init(
    logoUrl: URL(string: "https://i.pinimg.com/originals/6b/e7/43/6be743d83e3400ee1a7f64845b967efb.png"),
    name: "NearLondon1",
    coordinate: (-8.6345300, 115.2345579)
  ),
  .init(
    logoUrl: URL(string: "https://i1.wp.com/anantacreative.com/wp-content/uploads/2020/10/Restaurant-Logo1.png?resize=980%2C980&ssl=1"),
    name: "NearLondon2",
    coordinate: (-8.6383263, 115.2347964)
  ),
  .init(
    logoUrl: URL(string: "https://nice-branding.com/wp-content/uploads/2020/04/restaurant-logo-graphic-design-agency.png"),
    name: "Paris",
    coordinate: (-8.6364663, 115.2342405)
  ),
  .init(
    logoUrl: URL(string: "https://i.pinimg.com/originals/6b/e7/43/6be743d83e3400ee1a7f64845b967efb.png"),
    name: "",
    coordinate: (-8.6354580, 115.2360574)
  )
]

struct NearbyMapView: View {
  
  // 8,63721° S, 115,23504° E
  // (-8.6380511, 115.2357704) usr
  // (-8.6345300, 115.2345579) (-8.6345300, 115.2345579)
  // (-8.6383263, 115.2347964)
  // (-8.6364663, 115.2346405)
  @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: -8.6380511,
                                   longitude: 115.2357704),
    span: MKCoordinateSpan(latitudeDelta: 0.005,
                           longitudeDelta: 0.005)
  )
  
  private let locationManager = CLLocationManager()
  
  init() {
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  var body: some View {
    ZStack {
      MapView(
        coordinateRegion: region,
        annotations: merchants.map(MerchantAnnotation.init)
      )
      .ignoresSafeArea()
      
    }
  }
}

private extension NearbyMapView {
  struct MapView: UIViewRepresentable {
    var coordinateRegion: MKCoordinateRegion
    var annotations: [MKAnnotation]
    
    func makeCoordinator() -> Coordinator { .init() }
    
    func makeUIView(context: Context) -> MKMapView {
      let view = MKMapView()
      view.commonSetup()
      view.delegate = context.coordinator
      view.addAnnotations(annotations)
      view.setRegion(coordinateRegion, animated: true)
      return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
      
    }
  }
  
  final class Coordinator: NSObject, MKMapViewDelegate {
    func mapView(
      _ mapView: MKMapView,
      viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
      commonAnnotationViewSetup(mapView: mapView, annotation: annotation)
    }
    
    func mapView(
      _ mapView: MKMapView,
      didSelect view: MKAnnotationView
    ) {
      
    }
  }
}

struct NearbyMapView_Previews: PreviewProvider {
  static var previews: some View {
    NearbyMapView()
  }
}



/*
 WelcomeView - Cust
 SignIn - usr
 SignUp - cust
 
 home - cust
 detail - cust
 setting - cust
 
 nearby
 merchant home
 
 */


