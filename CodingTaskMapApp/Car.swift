import UIKit

protocol CarUpdateListener: AnyObject {
	func carUpdated(_ car: Car)
}

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
	var image: UIImage?
	
	enum CodingKeys: CodingKey {
		case id
		case modelIdentifier
		case modelName
		case name
		case make
		case group
		case color
		case series
		case fuelType
		case fuelLevel
		case transmission
		case licensePlate
		case latitude
		case longitude
		case innerCleanliness
		case carImageUrl
	}
	
	private static var updateListeners = [CarUpdateListener]()
	
	static func addListener(_ listener: CarUpdateListener) {
		Car.updateListeners.append(listener)
	}
	
	static func removeListener(_ listener: CarUpdateListener) {
		if let index = Car.updateListeners.firstIndex(where: { $0 === listener }) {
			Car.updateListeners.remove(at: index)
		}
	}
	
	func loadImage() {
		if image != nil { return }
		
		image = UIImage(named: "annotation") // Placeholder until loaded.
		
		guard let url = URL(string: carImageUrl) else { return }
		
		ImageCache.download(url: url) {
			if let image = $0 {
				DispatchQueue.main.async {
					self.image = image
					Car.updateListeners.forEach { $0.carUpdated(self) }
				}
			}
		}
	}
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
