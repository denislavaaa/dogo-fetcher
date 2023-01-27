import UIKit

public enum DogoFetcherError: Error {
    case invalidURL
    case badResponse
    case indexOutOfRange
    case galleryIsEmpty
}

public protocol DogoFetcherProtocol {
    func getImage() async throws -> UIImage
    func getImages(count: Int) async throws -> [UIImage]
    func getNextImage() async throws -> UIImage
    func getPreviousImage() async throws -> UIImage
    func resetGallery() async
    
    func setGalleryIndexObserver(_ observer: ((Int) -> Void)?) async
}

/// This object fetches images from the [Dog.ceo API](https://dog.ceo/dog-api)
/// and acts like a gallery by providing sequential access to images
public actor DogoFetcher: DogoFetcherProtocol {
    
    private let baseUrl = "https://dog.ceo/api/breeds/image/random"
    private var galleryIndexChangedAction: ((Int) -> Void)?
    
    private var currentIndex = -1 {
        didSet {
            galleryIndexChangedAction?(currentIndex)
        }
    }
    private var gallery: [String] = []

    
    public init() {}
    
    /// Add a closure to observe the current gallery index
    /// - Important: If no images are present in the gallery navigation, the index is -1
    public func setGalleryIndexObserver(_ observer: ((Int) -> Void)?) async {
        galleryIndexChangedAction = observer
    }
    
    /// Fetches a random dog picture and adds it to the gallery
    @discardableResult public func getImage() async throws -> UIImage {
        let singleDogoResponse: SingleDogoResponse = try await request(url: baseUrl)
        guard let imageUrl = URL(string: singleDogoResponse.message) else {
            throw DogoFetcherError.badResponse
        }
        gallery.append(singleDogoResponse.message)
        return try await fetchImage(imageUrl)
    }
    
    /// Fetches a specified number of dog images at ones and adds them to the gallery
    /// - Parameter count: The number of images to be fetched from the API
    @discardableResult public func getImages(count: Int) async throws -> [UIImage] {
        let manyDogosResponse: ManyDogosResponse = try await request(url: "\(baseUrl)/\(count)")
        gallery.append(contentsOf: manyDogosResponse.message)
        
        let allImages = try await withThrowingTaskGroup(
            of: UIImage.self,
            returning: [UIImage].self
        ) { [self] group in
            for imageUrlString in manyDogosResponse.message {
                group.addTask {
                    guard let imageUrl = URL(string: imageUrlString) else {
                        throw DogoFetcherError.invalidURL
                    }
                    return try await self.fetchImage(imageUrl)
                }
            }
            
            var images: [UIImage] = []
            for try await image in group {
                images.append(image)
            }
            return images
        }
        
        return allImages
    }
    
    /// Gets the next image from the gallery
    /// It can return an already fetched image or make an API call to get a random new image
    public func getNextImage() async throws -> UIImage {
        currentIndex += 1
        let image: UIImage
        if currentIndex < gallery.count && !gallery.isEmpty {
            guard let imageUrl = URL(string: gallery[currentIndex]) else {
                throw DogoFetcherError.invalidURL
            }
            image = try await fetchImage(imageUrl)
        } else {
            image = try await getImage()
        }
        return image
    }
    
    /// Gets the previous image from the gallery
    public func getPreviousImage() async throws -> UIImage {
        guard currentIndex > 0 else {
            throw DogoFetcherError.indexOutOfRange
        }
        currentIndex -= 1
        guard !gallery.isEmpty else {
            throw DogoFetcherError.galleryIsEmpty
        }
        guard let imageUrl = URL(string: gallery[currentIndex]) else {
            throw DogoFetcherError.invalidURL
        }
        return try await fetchImage(imageUrl)
    }
    
    /// Reset the gallery counter and all saved images
    public func resetGallery() {
        currentIndex = -1
        gallery = []
    }
    
    private func request<Response: Codable>(url: String) async throws -> Response {
        guard let url = URL(string: url) else {
            throw DogoFetcherError.invalidURL
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(Response.self, from: data)
        
        return response
    }
    
    public func fetchImage(_ url: URL) async throws -> UIImage {
        let urlRequest = URLRequest(url: url)
        let (imageData, _) = try await URLSession.shared.data(for: urlRequest)
        return UIImage(data: imageData)!
    }
}
