import UIKit

class CarListViewController: UITableViewController, MapControllerDisplaying {
	var mapController: MapController!
	private var progress = ProgressLayerController()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		progress.createView(in: self.view)
		
		mapController.errorHandler = { [weak self] error in
			guard let strongSelf = self else { return }
			strongSelf.progress.stop()
			ErrorPresenter.presentError(error, on: strongSelf)
		}
		mapController.updateHandler = { [weak self] in
			self?.progress.stop()
			self?.tableView.reloadData()
		}
		mapController.contentChangeHandler = { [weak self] car in
			self?.carUpdated(car)
		}

		do {
			progress.start()
			try mapController.update()
		} catch {
			ErrorPresenter.presentError(error, on: self)
		}
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(mapController.cars.count, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    	if mapController.cars.count == 0 {
			return tableView.dequeueReusableCell(withIdentifier: "com.thevoidsoftware.carlistviewcontroller.emptycell", for: indexPath)
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "com.thevoidsoftware.carlistviewcontroller.carcell", for: indexPath) as! CarTableViewCell

			let car = mapController.cars[indexPath.row]
			cell.carNameLabel.text = car.name
			cell.carModelLabel.text = car.modelName
			if let url = URL(string: car.carImageUrl) {
				cell.carImageView.image = ImageCache.cachedImage(url: url)
			} else {
				cell.carImageView.image = UIImage(named: "annotation")!
			}
			
        	return cell
		}
    }
}

extension CarListViewController: CarUpdateListener {
	func carUpdated(_ car: Car) {
		tableView.reloadData()
	}
}
