import UIKit

enum MapControllerError: Error {
	case invalidUrl
}

class MapController {
	/// The cached list of cars from the server.
	var cars = [Car]()
	var errorHandler: ((Error) -> Void)?
	var updateHandler: (() -> Void)?
	private var taskInProgress: URLSessionDataTask?

	/// Request the list of cars to be updated. Will asynchronously call errorHandler/updateHandler
	/// as needed on the main thread.
	/// Obtain list of cars from the cars property. If a request is in progress, this will do nothing
	/// and you'll only receive one callback when the original request finishes.
	func update() throws {
		guard taskInProgress == nil else { return } // They'll get what they want when the request returns.
	
		guard let url = URL(string: "https://cdn.sixt.io/codingtask/cars") else { throw MapControllerError.invalidUrl }
		
		taskInProgress = URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				DispatchQueue.main.async {
					self.taskInProgress = nil
					self.errorHandler?(error)
				}
				return
			}
			
			do {
				let decoder = JSONDecoder()
				let jsonData = try Data(contentsOf: url)
				let cars = try decoder.decode([Car].self, from: jsonData)
				cars.forEach {
					$0.loadImage()
				}
				self.cars = cars
				
				DispatchQueue.main.async {
					self.taskInProgress = nil
					self.updateHandler?()
				}
			} catch {
				DispatchQueue.main.async {
					self.taskInProgress = nil
					self.errorHandler?(error)
				}
			}
		}
		taskInProgress?.resume()
	}
}
