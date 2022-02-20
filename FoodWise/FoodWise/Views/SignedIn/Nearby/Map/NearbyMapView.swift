//
//  NearbyMapView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/11/21.
//

import SwiftUI

import MapKit

struct NearbyMapView: View {
  @StateObject private var viewModel: NearbyMapViewModel
  @State private var showsRadiusPicker = false
  @State private var tabBarHeight: CGFloat = 0.0
  static private var tabBarFrame: CGFloat? = nil
  @State private var tabBar: UITabBarController? = nil
  private let locationManager = CLLocationManager()
  
  init(viewModel: NearbyMapViewModel) {
    
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    ZStack {
      if let nearbyMerchants = viewModel.nearbyMerchants,
         let region = viewModel.region {
        MapView(
          coordinateRegion: region,
          annotations: nearbyMerchants.merchants.map(MerchantAnnotation.init)
        )
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
          Rectangle()
            .fill(Color.white)
            .frame(
              width: UIScreen.main.bounds.width,
              height:  120
            )
            .shadow(radius: 2)
            .overlay(alignment: .leading) {
              HStack(alignment: .top) {
                VStack(alignment: .leading) {
                  Text("WITHIN \(nearbyMerchants.radius.asString.uppercased())")
                    .font(.callout)
                  Text("\(nearbyMerchants.merchants.count) Merchants found")
                    .font(.headline)
                    .fontWeight(.bold)
                }
                Spacer()
                Button("Radius") {
                  showsRadiusPicker.toggle()
                }
                .disabled(showsRadiusPicker)
              }
              .padding(.horizontal)
              .padding(.bottom, 33)
              .overlay(alignment: .top) {
                HStack {
                  ForEach(NearbyRadius.allCases, id: \.rawValue) { radius in
                    Button(action: { viewModel.onChangeRadius(radius) }) {
                      ZStack {
                        RoundedRectangle(cornerRadius: 50)
                          .fill(
                            radius == viewModel.nearbyMerchants?.radius
                            ? Color.accentColor
                            : .white
                          )
                        RoundedRectangle(cornerRadius: 50)
                          .strokeBorder(
                            Color.secondary,
                            lineWidth: 2
                          )
                      }
                      .frame(height: 40)
                      .overlay {
                        Text("\(radius.asString)")
                          .foregroundColor(
                            radius == viewModel.nearbyMerchants?.radius
                            ? Color.white
                            : .secondary
                          )
                      }
                    }
                  }
                }
                .padding(.horizontal, 22)
                .padding(.bottom)
                .offset(y: showsRadiusPicker ? -70.0 : 0.0)
                .opacity(showsRadiusPicker ? 1 : 0)
                .animation(.easeIn, value: showsRadiusPicker)
                .disabled(!showsRadiusPicker)
              }
            }
            .onTapGesture { showsRadiusPicker = false }
            .offset(y: tabBarHeight)
            
        }
        .introspectTabBarController { controller in
          tabBarHeight = controller.tabBar.frame.height
//          tabBarHeight = controller.tabBar.frame.height
//          tabBar = controller
//          controller.tabBar.isHidden = true
//          controller.selectedViewController?.edgesForExtendedLayout = UIRectEdge.bottom
//          controller.selectedViewController?.extendedLayoutIncludesOpaqueBars = true
          /*
           tabBarController?.tabBar.isHidden = true
               edgesForExtendedLayout = UIRectEdge.bottom
               extendedLayoutIncludesOpaqueBars = true
           */
//          Self.tabBarFrame = controller.tabBar.frame.height
//          NotificationCenter.default.post(
//            name: .tabBarHiddenNotification,
//            object: nil)
          
        }
      } else {
        Color.backgroundColor.ignoresSafeArea()
        VStack {
          ProgressView().tint(.init(uiColor: .darkGray))
          Text("Loading Map")
        }
      }
    }
//    .onReceive(NotificationCenter.Publisher(
//      center: .default,
//      name: UIApplication.didBecomeActiveNotification)
//    ) { _ in
//        if let frame = Self.tabBarFrame {
//          DispatchQueue.main.async {
//            tabBarHeight = 83
//          }
//
//        }
//      }
//    }
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
      print("Update view")
      uiView.setRegion(coordinateRegion, animated: true)
      uiView.removeAnnotations(uiView.annotations)
      uiView.addAnnotations(annotations)
    }
  }
  
  final class Coordinator: NSObject, MKMapViewDelegate {
    func mapView(
      _ mapView: MKMapView,
      viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
      let view = commonAnnotationViewSetup(mapView: mapView, annotation: annotation)
      if let merchantAnnotation = annotation as? MerchantAnnotation {
        let calloutView = MerchantAnnotationCalloutView(
          merchant: merchantAnnotation.merchant).asUiView
        view?.canShowCallout = true
        view?.detailCalloutAccessoryView = calloutView
      }
      return view
    }
    
    func mapView(
      _ mapView: MKMapView,
      didSelect view: MKAnnotationView
    ) {
      
    }
  }
}

struct MerchantAnnotationCalloutView: View {
  var merchant: Merchant
  
  var body: some View {
    VStack(alignment: .leading, spacing: 2.5) {
      Text(merchant.name)
        .fontWeight(.bold)
        .fixedSize(horizontal: false, vertical: true)
      Text(merchant.location.geocodedLocation)
        .foregroundColor(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var asUiView: UIView {
    let view = UIHostingController(rootView: self).view!
    view.backgroundColor = .white
    return view
  }
}

//struct NearbyMapView_Previews: PreviewProvider {
//  static var previews: some View {
//    NearbyMapView(viewModel: .init(radiusChangedSubject: .init(),
//                                   filteredMerchantsPublisher: [[NearbyMerchants]]().publisher.eraseToAnyPublisher() )
//    )
//  }
//}
