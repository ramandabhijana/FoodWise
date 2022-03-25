//
//  LocationPickerViewController.swift
//  FoodWise
//
//  Created by Abhijana Agung Ramanda on 05/03/22.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!
  
  var completion: ((CLLocationCoordinate2D) -> Void)?
  var coordinates: CLLocationCoordinate2D?
  var isPickable = true
  
//  init(coordinates: CLLocationCoordinate2D?) {
//    self.coordinates = coordinates
//    self.isPickable = false
//    super.init(nibName: "LocationPickerViewController", bundle: Bundle.main)
//    view.isHidden = false
//  }
  
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if isPickable {
//      let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap(_:)))
      let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didTapMap(_:)))
//      gesture.numberOfTouchesRequired = 1
//      gesture.numberOfTapsRequired = 1
      gesture.minimumPressDuration = 1
      mapView.addGestureRecognizer(gesture)
    } else {
      // Just showing location
      guard let coordinates = self.coordinates else { return }
      // Drop a pin on that location
      let pin = MKPointAnnotation()
      pin.coordinate = coordinates
      mapView.addAnnotation(pin)
    }
  }
  
  @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
    let locationInView = gesture.location(in: mapView)
    let coordinates = mapView.convert(locationInView, toCoordinateFrom: mapView)
    self.coordinates = coordinates
    mapView.removeAnnotations(mapView.annotations)
    // Drop a pin on that location
    let pin = MKPointAnnotation()
    pin.coordinate = coordinates
    mapView.addAnnotation(pin)
  }

  @IBAction func didTapSendButton(_ sender: UIBarButtonItem) {
    guard let coordinates = coordinates else { return }
    completion?(coordinates)
  }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


