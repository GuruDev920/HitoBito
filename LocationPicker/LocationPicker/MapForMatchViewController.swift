import UIKit
import MapKit
import CoreLocation

final class MapForMatchViewController: UIViewController {
	
    struct CurrentLocationListener {
		let once: Bool
		let action: (CLLocation) -> ()
	}
    
	// region distance to be used for creation region when user selects place from search results
	public var resultRegionDistance: CLLocationDistance = 600
	
	/// default: true
	public var showCurrentLocationInitially = false

    /// default: false
    /// Select current location only if `location` property is nil.
    public var selectCurrentLocationInitially = true
	
	/// see `region` property of `MKLocalSearchRequest`
	/// default: false
	public var useCurrentLocationAsHint = false
	
	public var mapType: MKMapType = .standard {
		didSet {
			if isViewLoaded { mapView.mapType = mapType }
		}
	}
	
	public var location: Location? {
		didSet {
            
		}
	}
	
	static let SearchTermKey = "SearchTermKey"
	
	let historyManager = SearchHistoryManager()
	let locationManager = CLLocationManager()
	let geocoder = CLGeocoder()
	var localSearch: MKLocalSearch?
	var searchTimer: Timer?
	
	var currentLocationListeners: [CurrentLocationListener] = []
	
    lazy var mapView: MKMapView = {
        $0.mapType = mapType
        $0.showsCompass = false
        $0.showsScale = true
        
        return $0
    }(MKMapView())
    
    lazy var scaleView: MKScaleView = {
        $0.scaleVisibility = .visible
        return $0
    }(MKScaleView(mapView: mapView))
    
    lazy var locationButton: Button = {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        $0.layer.cornerRadius = 22
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.3
        $0.layer.shadowRadius = 5
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.masksToBounds = false
        $0.layer.shadowPath = UIBezierPath(roundedRect: $0.bounds, cornerRadius: 22).cgPath
        $0.setImage(#imageLiteral(resourceName: "map_location"), for: UIControl.State())
        $0.addTarget(self, action: #selector(MapForMatchViewController.currentLocationPressed),
                         for: .touchUpInside)
        return $0
    }(Button(frame: CGRect(x: 0, y: 0, width: 44, height: 44)))
	
	deinit {
		searchTimer?.invalidate()
		localSearch?.cancel()
		geocoder.cancelGeocode()
	}
	
	public override func loadView() {
		view = mapView
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
        mapView.addSubview(scaleView)
        mapView.addSubview(locationButton)
        
		locationManager.delegate = self
		mapView.delegate = self
        
		// gesture recognizer for adding by tap
        let locationSelectGesture = UILongPressGestureRecognizer(
            target: self, action: #selector(addLocation(_:)))
        locationSelectGesture.delegate = self
		mapView.addGestureRecognizer(locationSelectGesture)

        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .bottom
		definesPresentationContext = true
		
		// user location
		mapView.userTrackingMode = .none
		mapView.showsUserLocation = showCurrentLocationInitially
		
		if useCurrentLocationAsHint {
			getCurrentLocation()
		}
	}
	
	var presentedInitialLocation = false
	
    override public func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
        preferredContentSize.height = UIScreen.main.bounds.height
        
        locationButton.frame.origin = CGPoint(
            x: view.frame.width - locationButton.frame.width - 20,
            y: view.frame.height - locationButton.frame.height - 20
        )
		
		// setting initial location here since viewWillAppear is too early, and viewDidAppear is too late
		if !presentedInitialLocation {
			setInitialLocation()
			presentedInitialLocation = true
		}
	}
	
	func setInitialLocation() {
		if let location = location {
			// present initial location if any
			self.location = location
			showCoordinates(location.coordinate, animated: false)
            return
		} else if showCurrentLocationInitially || selectCurrentLocationInitially {
            if selectCurrentLocationInitially {
                let listener = CurrentLocationListener(once: true) { [weak self] location in
                    
                }
                currentLocationListeners.append(listener)
            }
			showCurrentLocation(false)
		}
	}
	
	func getCurrentLocation() {
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}
	
    @objc func currentLocationPressed() {
		showCurrentLocation()
	}
	
	func showCurrentLocation(_ animated: Bool = true) {
		let listener = CurrentLocationListener(once: true) { [weak self] location in
			self?.showCoordinates(location.coordinate, animated: animated)
		}
		currentLocationListeners.append(listener)
        getCurrentLocation()
	}
	
	func showCoordinates(_ coordinate: CLLocationCoordinate2D, animated: Bool = true) {
		let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: resultRegionDistance, longitudinalMeters: resultRegionDistance)
		mapView.setRegion(region, animated: animated)
	}
}

extension MapForMatchViewController: CLLocationManagerDelegate {
    
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.first else { return }
        currentLocationListeners.forEach { $0.action(location) }
		currentLocationListeners = currentLocationListeners.filter { !$0.once }
		manager.stopUpdatingLocation()
	}
}

// MARK: Searching

// MARK: Selecting location with gesture

extension MapForMatchViewController {
    @objc func addLocation(_ gestureRecognizer: UIGestureRecognizer) {
		if gestureRecognizer.state == .began {
			let point = gestureRecognizer.location(in: mapView)
			let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
			let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
			
			// clean location, cleans out old annotation too
			self.location = nil
		}
	}
}

// MARK: MKMapViewDelegate

extension MapForMatchViewController: MKMapViewDelegate {
	public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		return nil
	}
	
	public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if let navigation = navigationController, navigation.viewControllers.count > 1 {
			navigation.popViewController(animated: true)
		} else {
			presentingViewController?.dismiss(animated: true, completion: nil)
		}
	}
	
	public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
		let pins = mapView.annotations.filter { $0 is MKPinAnnotationView }
		assert(pins.count <= 1, "Only 1 pin annotation should be on map at a time")

        if let userPin = views.first(where: { $0.annotation is MKUserLocation }) {
            userPin.canShowCallout = false
        }
	}
}

extension MapForMatchViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: UISearchBarDelegate

extension MapForMatchViewController: UISearchBarDelegate {
	public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		// dirty hack to show history when there is no text in search bar
		// to be replaced later (hopefully)
		if let text = searchBar.text, text.isEmpty {
			searchBar.text = " "
		}
	}
	
	public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		// remove location if user presses clear or removes text
		if searchText.isEmpty {
			location = nil
			searchBar.text = " "
		}
	}
}
