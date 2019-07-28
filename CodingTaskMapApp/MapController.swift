import UIKit

enum MapControllerError: Error {
	case invalidUrl
	case disconnectedError
}

class MapController {
	/// The cached list of cars from the server.
	var cars = [Car]()
	var errorHandler: ((Error) -> Void)?
	var updateHandler: (() -> Void)?
	var contentChangeHandler: ((Car) -> Void)?
	private var taskInProgress: URLSessionDataTask?
	private var reachability = Reachability(hostName: "https://cdn.sixt.io/")

	/// Request the list of cars to be updated. Will asynchronously call errorHandler/updateHandler
	/// as needed on the main thread.
	/// Obtain list of cars from the cars property. If a request is in progress, this will do nothing
	/// and you'll only receive one callback when the original request finishes.
	func update() throws {
		guard taskInProgress == nil else { self.updateHandler?(); return } // They'll get what they want when the request returns, but balance the updateHandler callback.
	
		guard let url = URL(string: "https://cdn.sixt.io/codingtask/cars") else { throw MapControllerError.invalidUrl }
		
		taskInProgress = URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				DispatchQueue.main.async {
					self.taskInProgress = nil
					self.errorHandler?(error)
				}
				return
			}
			guard let data = data else {
				DispatchQueue.main.async {
					self.taskInProgress = nil
					if let reachability = self.reachability, !reachability.isReachable {
						self.errorHandler?(CommonError.offlineError)
					} else {
						self.errorHandler?(CommonError.urlNotFoundError)
					}
				}
				return
			}
			if let httpResponse = response as? HTTPURLResponse,
			 	httpResponse.statusCode == 404 {
				DispatchQueue.main.async {
					self.taskInProgress = nil
					self.errorHandler?(CommonError.urlNotFoundError)
				}
				return
			}

			do {
				let decoder = JSONDecoder()
				let cars = try decoder.decode([Car].self, from: data)
				self.cars = cars
				cars.forEach { car in
					if let url = URL(string: car.carImageUrl) {
						ImageCache.download(url: url) { _ in self.contentChangeHandler?(car) }
					}
				}

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
