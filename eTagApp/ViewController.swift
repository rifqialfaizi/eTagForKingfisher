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
    }
    
    func clearKingfisherCache() {
        KingfisherManager.shared.cache.clearCache()
        self.KingfisherCacheLabel.text = "Cache cleared"
        self.imageSourceLabel.text = "eTag cleared"
    }
    
    @IBAction func hitAPIButtonTapped(_ sender: UIButton) {
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



