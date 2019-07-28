import UIKit

/// An object that gets notified of changes to any car.
/// Use with `Car.addListener()` and `Car.removeListener()`.
protocol CarUpdateListener: AnyObject {
	func carUpdated(_ car: Car)
}

/// A Car as it is stored on the server.
/// I'm also caching the UIImage here, which is arguably a bit unclean.
class Car: Codable {
	var id: String = ""
	var modelIdentifier: String = ""
	var modelName: String = ""
	var name: String = ""
	var make: String = ""
	var group: String = ""
	var color: String = ""
	var series: String = ""
	var fuelType: String = ""
	var fuelLevel: Double = 0.0
	var transmission: String = ""
	var licensePlate: String = ""
	var latitude: Double = 0.0
	var longitude: Double = 0.0
	var innerCleanliness: String = ""
	var carImageUrl: String = ""
}

extension Car: CustomStringConvertible {
	var description: String {
		let mirror = Mirror(reflecting: self)
		var result = "\(String(describing: type(of: self))) {\n"
		for currProp in mirror.children {
			result.append("\"\(currProp.label ?? "?")\": \"\(currProp.value)\"\n") // Not escaping, this is just for debugging.
		}
		result.append("}")
		return result
	}
}
