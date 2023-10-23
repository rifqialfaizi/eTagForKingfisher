//
//  ViewController.swift
//  eTagApp
//
//  Created by Rifqi Alfaizi on 07/10/23.
//

import UIKit
import Alamofire
import Kingfisher

class ViewController: UIViewController, ImageDownloaderDelegate {
    
    @IBOutlet weak var bgImage: UIImageView! {
        didSet {
            bgImage.backgroundColor = .black
        }
    }
    @IBOutlet weak var hitAPIButton: UIButton!
    @IBOutlet weak var imageSourceLabel: UILabel!
    
    @IBOutlet weak var KingfisherCacheLabel: UILabel!
    
    // ETag value to be stored after the first hit
    var storedETag: String?
    
    // Your image URL and headers
    let imageURL = "https://tdwstcontent.telkomsel.com/sites/default/files/images/pages/assets/background-min.png"
    var headers: HTTPHeaders = [:]
    
    let downloader = KingfisherManager.shared.downloader  // Or another downloader if you are not using the default one.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageSourceLabel.text = ""
        self.KingfisherCacheLabel.text = ""
//        downloader.delegate = self
    }
    
//    func getImageRequest() {
//        AF.request(imageURL, method: .head, headers: headers)
//            .validate(statusCode: 200..<300)
//            .response { response in
//                switch response.result {
//                case .success:
//                    if let etag = response.response?.allHeaderFields["Etag"] as? String {
//                        self.storedETag = etag
//                        self.imageSourceLabel.text = "Image AF loaded from network"
//                    }
//                case .failure(let error):
//                    print("✅ Request failed with error: \(error)")
//                }
//            }
//    }
    
//    func imageDownloader(_ downloader: ImageDownloader, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
//           // Check if the response is an HTTP response (in case of non-HTTP responses)
//           guard let httpResponse = response as? HTTPURLResponse else {
//               completionHandler(.allow)
//               return
//           }
//
//           if let etag = httpResponse.allHeaderFields["Etag"] as? String {
//               self.storedETag = etag
//               print("✅ etag inside imageDownloader: \(etag)")
//           }
//
//           // Allow the response to proceed
//           completionHandler(.allow)
//    }
    
//    func loadImageWithKingfisher() {
//        let etag = storedETag ?? ""
//        let requestModifier = MyRequestModifier(etag: etag)
//            let options: KingfisherOptionsInfo = [.forceRefresh, .requestModifier(requestModifier)]
//
//            bgImage.kf.setImage(with: imageURL, options: options, completionHandler: { result in
//                switch result {
//                case .success(let value):
//                    // Image loaded successfully
//                    if value.cacheType == .none {
////                        self.getImageRequest()
//                        print("✅ Image loaded from network.")
//                        self.KingfisherCacheLabel.text = "Image KF loaded from network"
//                    } else if value.cacheType == .memory {
//                        print("✅ Image loaded from cache.")
//                        self.KingfisherCacheLabel.text = "Image KF loaded from cache"
//                    }
//                case .failure(let error):
//                    print("✅ error: \(error)")
//                    self.bgImage.kf.setImage(with: self.imageURL, options: nil)
//                    self.KingfisherCacheLabel.text = "Image KF loaded from cache"
//                    self.imageSourceLabel.text = ""
//                }
//            })
//    }
    
    func clearKingfisherCache() {
        KingfisherManager.shared.cache.clearCache()
        self.KingfisherCacheLabel.text = "Cache cleared"
        self.imageSourceLabel.text = "eTag cleared"
    }
    
    @IBAction func hitAPIButtonTapped(_ sender: UIButton) {
//        loadImageWithKingfisher()
        ImageAssetHelper.fetchImageIn2(bgImage, url: imageURL, placeholder: nil)
    }
    
    @IBAction func clearCaheButtonTapped(_ sender: Any) {
        clearKingfisherCache()
        storedETag = ""
        print("✅ cache cleared")
    }
}

class MyRequestModifier: ImageDownloadRequestModifier {

    let etag: String

    init(etag: String) {
        self.etag = etag
    }

    func modified(for request: URLRequest) -> URLRequest? {
        var modifiedRequest = request
        modifiedRequest.setValue(etag, forHTTPHeaderField: "If-None-Match")
        return modifiedRequest
    }
}



