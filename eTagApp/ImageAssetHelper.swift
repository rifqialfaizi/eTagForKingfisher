//
//  ImageAssetHelper.swift
//  eTagApp
//
//  Created by PT Phincon on 19/10/23.
//

import Foundation
import UIKit
import Kingfisher
import Alamofire

public final class ImageAssetsCache: NSObject {
    
    private override init() {}
    
    public static func configCache(cache: ImageCache) -> ImageCache {
        // reference: https://github.com/onevcat/Kingfisher/issues/1584
        // Limit memory cache size to 250 MB and check memory clean up every 10 seconds.
        cache.memoryStorage.config = MemoryStorage.Config.init(
            totalCostLimit: 1024 * 1024 * 250,
            cleanInterval: 100
        )
        // Memory image expires after 1 minute.
        cache.memoryStorage.config.expiration = .seconds(60)
        cache.diskStorage.config.expiration = .seconds(60)
        return cache
    }
}

public final class ImageAssetHelper: NSObject {
    
    private override init() { }
    
    static var storedEtag : String = ""
    static var headers : HTTPHeaders = [:]
    
    
    // MARK: - Method
    
    public static func fetchImageIn2(_ imageView: UIImageView, url: String?, placeholder: UIImage?) {
        
        guard let url = url else {
            // Default Image
            imageView.image = placeholder
            return
        }
        
        // Check valid URL string
        if let link = URL(string: url) {
            // Add regular UIImageView
            let options = getKingfisherOptions(url: link, withEtag: true)
            imageView.kf.setImage(with: link, options: options, completionHandler: { (result) in
                switch result {
                case .success(let value):
                    if value.cacheType == .none {
                        getEtagForWcmsAsset(wcmsAssetUrl: url)
                        print("✅ Image loaded from network.")
                    } else if value.cacheType == .memory {
                        print("✅ Image loaded from cache.")
                    }
                    break
                case .failure(let error):
                    print("✅ error fetchImage: \(error)")
                    print("✅ imgURL: \(link)")
                    imageView.kf.setImage(with: link, options: nil)
                    // Default Image
            //        imageView.image = placeholder
                }
            })
        } else {
            
            // Default Image
            imageView.image = placeholder
        }
    }
    
    private static func getKingfisherOptions(url: URL, withEtag: Bool = false) -> KingfisherOptionsInfo {
        let cache = ImageAssetsCache.configCache(cache: ImageCache(name: url.absoluteString))
        var options: KingfisherOptionsInfo = []
        
        if withEtag {
            print("✅ storedEtag: \(storedEtag)")
            let requestModifier = MyRequestModifier(etag: storedEtag)
            options = [.forceRefresh, .requestModifier(requestModifier)]
        } else {
            options = []
        }
      
        options.append(.targetCache(cache))
        return options
    }
    
    //MARK: ALAMOFIRE ASSET
    public static func getEtagForWcmsAsset(wcmsAssetUrl: String = "") {
        Alamofire.request(wcmsAssetUrl, method: .head, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
            switch response.result {
            case .success:
                if let etag = response.response?.allHeaderFields["Etag"] as? String {
                    self.storedEtag = etag
                    print("✅ Image AF loaded from network \(etag)")
                }
                break
            case .failure(let error):
                print("✅ Request failed with error: \(error)")
                break
            }
        }
    }
}
