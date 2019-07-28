import UIKit
import MapKit


class CarMapViewController: UIViewController, MKMapViewDelegate {
	@IBOutlet var mapView: MKMapView!
	var mapController = MapController()
	private var annotations = [CarAnnotation]()
	private var firstLoad = true
	
	deinit {
		Car.removeListener(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		Car.addListener(self)
		
		mapController.errorHandler = { [weak self] error in
			self?.presentError(error)
		}
		mapController.updateHandler = { [weak self] in
			self?.rebuildAnnotations()
		}

		do {
			try mapController.update()
		} catch {
			presentError(error)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		rebuildAnnotations()
	}
	
	func rebuildAnnotations() {
		mapView.removeAnnotations(annotations)
		annotations = mapController.cars.map {
			let annotation = CarAnnotation(car: $0)
			return annotation
		}
		mapView.addAnnotations(annotations)
		
		if firstLoad && mapView != nil && !annotations.isEmpty {
			firstLoad = false
			DispatchQueue.main.async {
				self.mapView.showAnnotations(self.annotations, animated: false)
			}
		}
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "com.thevoidsoftware.carmapviewcontroller.carannotation")
		if let annotation = annotation as? CarAnnotation {
			annotation.view = annotationView
			annotationView.image = annotation.image
		}
		return annotationView
	}
	
	func presentError(_ error: Error) {
		let alert = UIAlertController(title: "Failed to fetch car list", message: error.localizedDescription, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Fetch failed error Default action"), style: .default, handler: nil))
		self.present(alert, animated: true) {
			// Done.
		}
	}
}

extension CarMapViewController: CarUpdateListener {
	func carUpdated(_ car: Car) {
		if let annotation = annotations.first(where: { $0.car === car }) {
			annotation.view?.image = car.image
		}
	}
}

// Could just make this an extension on Car, but that feels like premature optimization and a layering violation.
class CarAnnotation: NSObject, MKAnnotation {
	var car: Car
	var image: UIImage? { return car.image }
	weak var view: MKAnnotationView?
    var title: String? { return car.name }
    var subtitle: String? { return car.modelName }
	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: car.latitude, longitude: car.longitude)
	}

	init(car: Car) {
		self.car = car
	}
}
