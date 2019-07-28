import UIKit

class ImageEntry {
	var image: UIImage?
	var completions = [(UIImage?) -> Void]()
	
	init(completion: @escaping (UIImage?) -> Void) {
		completions.append(completion)
	}
}

class ImageCache {
	private static var urlToImage = [URL: ImageEntry]()
	private static let imageWidthHeight = CGFloat(64.0)

	static func download(url: URL, completion: @escaping (UIImage?) -> Void) {
		// TODO: Should expire images from cache.
		// Anything in cache?
		if let foundEntry = urlToImage[url] {
			if let image = foundEntry.image { // Is not a load-in-progress?
				completion(image)
			} else {
				foundEntry.completions.append(completion)
			}
			return
		}
		
		let imageEntry = ImageEntry(completion: completion)
		urlToImage[url] = imageEntry // Add placeholder so we don't start 2 downloads.
		
		let loadTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard error == nil, let data = data else {
				print("failed to load image: \(String(describing: error))");
				DispatchQueue.main.async {
					let completions = imageEntry.completions
					imageEntry.completions = []
					imageEntry.image = UIImage(named: "annotation")
					completions.forEach { $0(imageEntry.image) }
				}
				return
			}
			if let image = UIImage(data: data) {
				var box = CGRect.zero
				box.size = image.size
				if box.width > box.height {
					box.size.height = CGFloat(truncf(Float(box.height * (imageWidthHeight / box.width))))
					box.size.width = imageWidthHeight
				} else {
					box.size.width = CGFloat(truncf(Float(box.width * (imageWidthHeight / box.height))))
					box.size.height = imageWidthHeight
				}
				UIGraphicsBeginImageContext(box.size)
				image.draw(in: box)
				let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
				DispatchQueue.main.async {
					imageEntry.image = scaledImage
					let completions = imageEntry.completions
					imageEntry.completions = []
					completions.forEach { $0(imageEntry.image) }
				}
			}
		}
		loadTask.resume()
	}
}
