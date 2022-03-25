//
//  CoordinateMapViewerView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 15/03/22.
//

import SwiftUI
import MapKit
import CoreLocation

struct CoordinateMapViewerView: View {
  @State private var region: MKCoordinateRegion
  let items: [MapItem]
  
  init(region: MKCoordinateRegion, coordinates: [CLLocationCoordinate2D]) {
    _region = State(initialValue: region)
    items = coordinates.map(MapItem.init)
  }
  
  var body: some View {
    Map(
      coordinateRegion: $region,
      annotationItems: items
    ) { item in
      MapKit.MapAnnotation(coordinate: item.coordinate) {
        FoodWiseAnnotationView(imageUrl: nil)
      }
    }
  }
}

struct MapItem: Identifiable {
  let id = UUID()
  var coordinate: CLLocationCoordinate2D
}

//struct FoodWiseMapView_Previews: PreviewProvider {
//  static var previews: some View {
//    CoordinateMapViewerView()
//  }
//}
