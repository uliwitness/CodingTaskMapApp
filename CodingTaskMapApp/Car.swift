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
	
	static let imageWidthHeight = CGFloat(64.0)
	
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
		guard let url = URL(string: carImageUrl) else { return }
		
		// Could have global cache here to prevent fetching images repeatedly.
		
		let loadTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard error == nil, let data = data else { print("failed to load image: \(String(describing: error))"); return }
			if let image = UIImage(data: data) {
				var box = CGRect.zero
				box.size = image.size
				if box.width > box.height {
					box.size.height = CGFloat(truncf(Float(box.height * (Car.imageWidthHeight / box.width))))
					box.size.width = Car.imageWidthHeight
				} else {
					box.size.width = CGFloat(truncf(Float(box.width * (Car.imageWidthHeight / box.height))))
					box.size.height = Car.imageWidthHeight
				}
				UIGraphicsBeginImageContext(box.size)
				image.draw(in: box)
				self.image = UIGraphicsGetImageFromCurrentImageContext()
				DispatchQueue.main.async {
					Car.updateListeners.forEach { $0.carUpdated(self) }
				}
			}
		}
		loadTask.resume()
		
		image = UIImage(named: "annotation") // Placeholder until loaded.
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
