import UIKit

protocol MapControllerDisplaying: AnyObject {
	var mapController: MapController! { get set }
}

class MainTableViewController: UITableViewController {
	var mapController = MapController()
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let viewController = segue.destination as? MapControllerDisplaying {
			viewController.mapController = mapController
		}
	}
}
