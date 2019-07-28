import UIKit
import MapKit


class CarMapViewController: UIViewController, MKMapViewDelegate, MapControllerDisplaying {
	@IBOutlet var mapView: MKMapView!
	private var progress = ProgressLayerController()
	var mapController: MapController!
	private var annotations = [CarAnnotation]()
	private var firstLoad = true
	
	deinit {
		Car.removeListener(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		progress.createView(in: self.view)
		
		Car.addListener(self)
		
		mapController.errorHandler = { [weak self] error in
			guard let strongSelf = self else { return }
			strongSelf.progress.stop()
			ErrorPresenter.presentError(error, on: strongSelf)
		}
		mapController.updateHandler = { [weak self] in
			self?.progress.stop()
			self?.rebuildAnnotations()
		}

		do {
			progress.start()
			try mapController.update()
		} catch {
			ErrorPresenter.presentError(error, on: self)
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
		
	func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
		progress.start()
	}
	
	func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
		progress.stop()
	}
	
	func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
		progress.stop()
		ErrorPresenter.presentError(error, on: self)
	}

	func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
		progress.start()
	}

	func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
		progress.stop()
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
