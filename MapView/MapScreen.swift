//
//  ViewController.swift
//  MapView
//
//  Created by Jesther Silvestre on 6/28/21.
//

import UIKit
import MapKit
import CoreLocation
class MapScreen: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    let locationManager = CLLocationManager()
    let mapAreaZoom:Double = 1000
    var previousLocation:CLLocation?
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: location, latitudinalMeters: mapAreaZoom, longitudinalMeters: mapAreaZoom)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func setupLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func checkLocationAuthorization(){
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            //setup of map
            startTrackingUserLocation()
        case .denied:
            //show alert instructing them how to turn it on
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //show alert that it's not possible to turn it on
            break
        case .authorizedAlways:
            break
        default:
            break
        }
    }
    
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            //setup of location manager
            setupLocation()
            checkLocationAuthorization()
        }
        else{
            //show user how to enable location service
        }
    }
    
    func getCenterLocation(for mapView: MKMapView)-> CLLocation{
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension MapScreen:CLLocationManagerDelegate{
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else{return}
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, latitudinalMeters: mapAreaZoom, longitudinalMeters: mapAreaZoom)
//        mapView.setRegion(region, animated: true)
//    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

extension MapScreen:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard var previousLocation = previousLocation else {return}
        guard center.distance(from: previousLocation) > 50 else{return}
        previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) {[weak self] placemarks, error in
            guard let self = self else {return}
            
            if let _ = error{
                //TODO: show alert informing the user
            }
            
            guard let placemark = placemarks?.first else{
                //TODO: show alert informing the user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
}

