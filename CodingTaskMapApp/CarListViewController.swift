//
//  ListViewController.swift
//  CodingTaskMapApp
//
//  Created by Uli Kusterer on 28.07.19.
//  Copyright © 2019 Uli Kusterer. All rights reserved.
//

import UIKit

class CarListViewController: UITableViewController {
	var mapController = MapController()
	private var progress = ProgressLayerController()

	deinit {
		Car.removeListener(self)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		progress.createView(in: self.view)
		
		Car.addListener(self)

		mapController.errorHandler = { [weak self] error in
			self?.progress.stop()
			self?.presentError(error)
		}
		mapController.updateHandler = { [weak self] in
			self?.progress.stop()
			self?.tableView.reloadData()
		}

		do {
			progress.start()
			try mapController.update()
		} catch {
			presentError(error)
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

			cell.carNameLabel.text = mapController.cars[indexPath.row].name
			cell.carModelLabel.text = mapController.cars[indexPath.row].modelName
			cell.carImageView.image = mapController.cars[indexPath.row].image
			
        	return cell
		}
    }
	
	func presentError(_ error: Error) {
		print("error = \(error)")
		let alert = UIAlertController(title: "Failed to fetch car list", message: error.localizedDescription, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Fetch failed error Default action"), style: .default, handler: nil))
		self.present(alert, animated: true) {
			// Done.
		}
	}
}

extension CarListViewController: CarUpdateListener {
	func carUpdated(_ car: Car) {
		tableView.reloadData()
	}
}
