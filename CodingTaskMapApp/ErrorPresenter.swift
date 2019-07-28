import UIKit

enum CommonError: Error {
	case offlineError
	case urlNotFoundError
	
	var localizedDescription: String {
		switch self {
			case .offlineError:
				return "You are not connected to the internet."
			case .urlNotFoundError:
				return "Some data could not be downloaded. Check if there is an update to Cars app available."
		}
	}
}

class ErrorPresenter {
	static func presentError(_ error: Error, on viewController: UIViewController) {
		let alert = UIAlertController(title: "Failed to fetch car list", message: error.localizedDescription, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Fetch failed error Default action"), style: .default, handler: nil))
		viewController.present(alert, animated: true) {
			// Done.
		}
	}
}
