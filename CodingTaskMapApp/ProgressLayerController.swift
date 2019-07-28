import UIKit

class ProgressLayerController: NSObject {
	private var progressContainer: UIView?
	private var progressVisibleCount = 0

	/// Create a progress indicator overlay view centered in the given parent view.
	func createView(in parentView: UIView) {
		let container = UIView(frame: .zero)
		container.translatesAutoresizingMaskIntoConstraints = false
		parentView.addSubview(container)
		container.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
		container.centerYAnchor.constraint(equalTo: parentView.centerYAnchor).isActive = true
		container.layer.cornerRadius = CGFloat(8.0)
		container.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7)
		let progress = UIActivityIndicatorView(frame: .zero)
		progress.translatesAutoresizingMaskIntoConstraints = false
		container.addSubview(progress)
		progress.leftAnchor.constraint(equalTo: container.leftAnchor, constant: CGFloat(8.0)).isActive = true
		progress.topAnchor.constraint(equalTo: container.topAnchor, constant: CGFloat(8.0)).isActive = true
		progress.rightAnchor.constraint(equalTo: container.rightAnchor, constant: CGFloat(-8.0)).isActive = true
		progress.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: CGFloat(-8.0)).isActive = true
		progress.style = .whiteLarge
		progress.startAnimating()
		progressContainer = container
	}

	/// Request that progress be shown as you're doing something. You *must* balance every call
	/// to start() with a call to stop().
	func start() {
		progressVisibleCount += 1
		progressContainer?.isHidden = (progressVisibleCount == 0)
	}
	
	/// Inform the progress indicator that the progress requested using start() has completed.
	func stop() {
		progressVisibleCount -= 1
		progressContainer?.isHidden = (progressVisibleCount == 0)
	}
}
