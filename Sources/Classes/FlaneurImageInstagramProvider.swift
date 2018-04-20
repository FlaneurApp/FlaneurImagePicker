//
//  FlaneurImageInstagramProvider.swift
//  FlaneurImagePickerController
//
//  Created by Flâneur on 24/07/2017.
//  
//

import UIKit
import SafariServices

enum FlaneurImageInstagramProviderError: LocalizedError {
    case instagramInvalidURL

    case instagramEmptyData

    case instagramInvalidJSON
}

/// User's instagram source, needs "InstagramClientID" and "InstagramRedirectURI" set in info.plist
final class FlaneurImageInstagramProvider: NSObject, FlaneurImageProvider {
    weak var delegate: FlaneurImageProviderDelegate?

    let name = "instagram"

    let loginManager: InstagramLoginManager = {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "InstagramClientID") as? String,
            let redirectURI = Bundle.main.object(forInfoDictionaryKey: "InstagramRedirectURI") as? String else {
                fatalError("please configure `InstagramClientID` and `InstagramRedirectURI` in your main bundle plist file.")
        }

        return InstagramLoginManager(clientID: clientID, redirectURI: redirectURI)
    }()

    var nextPageURL: URL?
    
    func isAuthorized() -> Bool {
        return InstagramLoginManager.currentAccessToken != nil
    }

    func requestAuthorization(_ handler: @escaping (Bool) -> Void) {
        guard let presentingViewController = delegate?.presentingViewController(for: self) else { return }
        loginManager.authenticate(from: presentingViewController,
                                  completionHandler: handler)
    }

    func fetchImagesFromSource() {
        fetchUserPictures()
    }

    // MARK: - Instagram Parsing

    func parseData(data: [String: AnyObject]) {
        // Failure => http code != 200, we present the login view to the user once again,
        // access_token might be dead
        guard let meta = data["meta"],
            let code = meta["code"] as? Int, code == 200 else {
                requestAuthorization { [weak self] isAuthenticated in
                    self?.fetchUserPictures()
                }
                return
        }

        // Success => http code == 200
        // Parse pagination if exists
        if let pagination = data["pagination"] as? [String: AnyObject],
            let nextURLString = pagination["next_url"] as? String {
            nextPageURL = URL(string: nextURLString)!
        } else {
            nextPageURL = nil
        }

        // Parse data
        var images = [FlaneurImageDescriptor]()
        for data in (data["data"] as? [[String: AnyObject]])! {
            guard let dataImages = data["images"] as? [String: AnyObject], (data["type"] as! String) == "image",
                let image = dataImages["standard_resolution"] as? [String: AnyObject],
                let imageStringURL = image["url"] as? String else {
                    continue
            }

            guard let imageURL = URL(string: imageStringURL) else {
                continue
            }

            images.append(.url(imageURL))
        }

        delegate?.imageProvider(self, didLoadImages: images)
    }
    
    func fetchUserPictures(withURL maybeURL: URL? = nil) {
        guard let url = maybeURL ?? loginManager.mediaURL() else {
            delegate?.imageProvider(self, didFailWithError: FlaneurImageInstagramProviderError.instagramInvalidURL)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, resp, error in
            guard let data = data else {
                guard let existingSelf = self else { return }
                existingSelf.delegate?.imageProvider(existingSelf, didFailWithError: FlaneurImageInstagramProviderError.instagramEmptyData)
                return
            }

            do {
                if let dictionaryOK = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    self?.parseData(data: dictionaryOK)
                }
            } catch {
                print(error)
                guard let existingSelf = self else { return }
                existingSelf.delegate?.imageProvider(existingSelf, didFailWithError: FlaneurImageInstagramProviderError.instagramInvalidJSON)
            }
        }
        task.resume()
    }
    
    func fetchNextPage() {
        guard let nextURL = nextPageURL else {
            delegate?.imageProvider(self, didLoadImages: [])
            return
        }
        fetchUserPictures(withURL: nextURL)
    }
}
