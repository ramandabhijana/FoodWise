//
//  SelectLocationView.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 19/11/21.
//

import SwiftUI
import MapKit
import Combine

struct SelectLocationViewTest: View {
  @State private var coordinate: CLLocationCoordinate2D? = nil
  @State private var details = ""
  
  var body: some View {
    NavigationView {
      VStack {
        NavigationLink("Select location") {
          SelectLocationView(viewModel: .init()) { coordinate, details in
            print(coordinate)
          
            self.coordinate = coordinate
            self.details = details
          }
        }
        if let coordinate = coordinate {
          Text("coordinate: lat\(coordinate.latitude), long\(coordinate.longitude)")
          Text(details)
        }
      }
    }
  }
}

struct SelectLocationView: View {
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject private var viewModel: SelectLocationViewModel
  private let onSave: (_ coordinate: CLLocationCoordinate2D, _ details: String) -> Void
  
  typealias SaveAddressCompletion = (_ coordinate: CLLocationCoordinate2D, _ details: String) -> Void
  
  init(viewModel: SelectLocationViewModel,
       onSave: @escaping SaveAddressCompletion)
  {
    self.viewModel = viewModel
    self.onSave = onSave
  }
  
  var body: some View {
    if let region = viewModel.region {
      ZStack {
        MapView(
          region: region,
          coordinate: $viewModel.coordinate
        )
        .ignoresSafeArea()
      }
      .navigationBarHidden(true)
      .overlay(alignment: .top) {
        HStack {
          Button(
            action: { },
            label: {
              Image(systemName: "xmark")
                .foregroundColor(.init(uiColor: .darkGray))
            }
          )
          Spacer()
          VStack {
            Text("Select Location")
              .bold()
              .font(.headline)
            Text("Tap and hold on the desired location")
              .font(.subheadline)
          }
          Spacer()
        }
        .padding(.horizontal)
        .frame(width: UIScreen.main.bounds.width)
        .padding(.bottom, 5)
        .background(Color.backgroundColor.opacity(0.7))
        .padding(.top, 48) // safe area height
        .edgesIgnoringSafeArea(.top)
        
        
      }
      .overlay(alignment: .bottom) {
        if let selectedCoordinate = viewModel.coordinate {
          VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
              makeItem(
                title: "Location",
                subtitle: viewModel.geocodedLocation
              )
              makeItem(
                title: "Coordinate",
                subtitle: "(\(selectedCoordinate.latitude), \(selectedCoordinate.longitude))"
              )
              
              VStack(alignment: .leading, spacing: 5) {
                HStack {
                  Text("Address Details").bold()
                  Text("(Optional)").fontWeight(.light).font(.subheadline)
                }
                TextEditor(text: $addressDetailsText)
                  .disableAutocorrection(true)
                  .frame(height: 90)
  //                .if(textEditorText.isEmpty) { view in
  //                  view.overlay(alignment: .topLeading) {
  //                    Text("You can specify things like house number, postal code, floor, etc.")
  //                      .foregroundColor(.secondary.opacity(0.5))
  //                      .padding(5)
  //                  }
  //                }
              }
            }
            .padding()
            
            .background(Color.backgroundColor)
            .cornerRadius(20)
            
            HStack {
              Button(
                action: viewModel.resetCoordinate,
                label: {
                  RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(height: 48)
                    .overlay {
                      RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.accentColor)
                    }
                    .overlay {
                      Text("Reselect")
                        .bold()
                    }
                }
              )
              
              Button(
                action: {
                  onSave(selectedCoordinate, addressDetailsText)
                  presentationMode.wrappedValue.dismiss()
                },
                label: {
                  RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor)
                    .frame(height: 48)
                    .overlay {
                      Text("Save")
                        .bold()
                        .foregroundColor(.white)
                    }
                }
              )
            }
            
            
          }
          .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .leading)
          .padding(.bottom, 28)
          .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
          
//          .opacity(viewModel.coordinateIsSet ? 1 : 0)
//          .animation(.easeIn, value: viewModel.coordinateIsSet)
        } 
      }
      
    } else {
      Text("Please allow location access")
    }
  }
  
  // TODO: Move this and the content of overlay(.top) to another struct
  @State private var addressDetailsText = ""
  
  
  func makeItem(title: String, subtitle: String) -> some View {
    VStack(alignment: .leading) {
      Text(title).bold()
      Text(subtitle)
    }
  }
}

struct SelectocationView_Previews: PreviewProvider {
  static var previews: some View {
    SelectLocationView(viewModel: .init(coordinate: CLLocationCoordinate2D(latitude: -8.6380511,
                                                                           longitude: 115.2358704)), onSave: {_, _ in })
  }
}



class SelectLocationViewModel: ObservableObject {
  
  //
  @Published public private(set) var region: MKCoordinateRegion? = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: -8.6380511, // -8.63 5 0511
                                   longitude: 115.2357704),
    span: MKCoordinateSpan(latitudeDelta: 0.005,
                           longitudeDelta: 0.005)
  )
  @Published public private(set) var geocodedLocation = ""
  
//  @Published public private(set) var region: MKCoordinateRegion? = nil
//  @Published public private(set) var geocodedLocation = ""
  @Published internal var coordinate: CLLocationCoordinate2D? {
    didSet {
      print("coordinate was set: \(String(describing: coordinate))")
      guard let coordinate = coordinate else {
        coordinateIsSet = false
        return
      }
      coordinateIsSet = true
//      Task { await geocodeLocation(coordinate: coordinate) }
    }
  }
  @Published private(set) var coordinateIsSet = false
  
  private var subscriptions = Set<AnyCancellable>()
  
  init(coordinate: CLLocationCoordinate2D? = nil) {
    self.coordinate = coordinate
    if let coordinate = coordinate {
      self.region = MKCoordinateRegion(center: coordinate, span: span)
    } else {
      LocationManager.shared.locationPublisher
        .sink { [weak self] location in
          guard let self = self else { return }
          print("Received location: \(location)")
          self.region = MKCoordinateRegion(center: location.coordinate,
                                           span: span)
          LocationManager.shared.stopLocationService()
        }
        .store(in: &subscriptions)
    }
  }
  
  @MainActor
  private func geocodeLocation(coordinate: CLLocationCoordinate2D) async {
    do {
      let location = CLLocation(latitude: coordinate.latitude,
                                longitude: coordinate.longitude)
      geocodedLocation = try await Geocoder.shared.reverseGeocode(location: location)
    } catch let error as GeocodingError {
      geocodedLocation = error.rawValue
    } catch {
      print(error)
    }
  }
  
  func resetCoordinate() {
    coordinate = nil
  }
}

// MARK: - MapView
private extension SelectLocationView {
  struct MapView: UIViewRepresentable {
    var region: MKCoordinateRegion
    @Binding var coordinate: CLLocationCoordinate2D?
    
    func makeCoordinator() -> Coordinator { .init(coordinate: $coordinate) }
    
    func makeUIView(context: Context) -> MKMapView {
      let view = MKMapView()
      view.commonSetup()
      view.setRegion(region, animated: true)
      view.delegate = context.coordinator
      let longPressRecognizer = UILongPressGestureRecognizer(
        target: view,
        action: #selector(view.addAnnotationOnLongPress(_:))
      )
      view.addGestureRecognizer(longPressRecognizer)
      if let coordinate = coordinate {
        let annotation = MapAnnotation(coordinate: coordinate)
        view.addAnnotation(annotation)
      }
      return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
      print("updateview")
      if coordinate == nil,
         uiView.annotations.count > 1,
         let unwantedAnnotation = uiView.annotations.first(where: { $0 is FWAnnotation }) {
        uiView.removeAnnotation(unwantedAnnotation)
      }
    }
  }
  
  final class Coordinator: NSObject, MKMapViewDelegate {
    @Binding var coordinate: CLLocationCoordinate2D?
    
    init(coordinate: Binding<CLLocationCoordinate2D?>) {
      self._coordinate = coordinate
    }
    
    func mapView(
      _ mapView: MKMapView,
      viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
      commonAnnotationViewSetup(mapView: mapView, annotation: annotation)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
      guard mapView.annotations.count > 1 else { return }
      print("mapView.annotations: \(mapView.annotations)")
      let addedAnnotation = mapView.annotations.first { $0 is FWAnnotation }
      if let coordinate = addedAnnotation?.coordinate {
        self.coordinate = coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01,
                                    longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
      }
      
    }
  }
}

private extension MKMapView {
  @objc func addAnnotationOnLongPress(_ gestureRecognizer: UIGestureRecognizer) {
    if gestureRecognizer.state == .began {
      removeAnnotations(annotations)
      let point = gestureRecognizer.location(in: gestureRecognizer.view)
      guard let mapView = gestureRecognizer.view as? MKMapView else { return }
      let coordinate = mapView.convert(point,
                                       toCoordinateFrom: gestureRecognizer.view)
      let annotation = MapAnnotation(coordinate: coordinate)
      addAnnotation(annotation)
    }
  }
}

fileprivate let span = MKCoordinateSpan(latitudeDelta: 0.005,
                                        longitudeDelta: 0.005)
