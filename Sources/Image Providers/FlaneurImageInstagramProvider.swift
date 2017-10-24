//
//  FlaneurImageInstagramProvider.swift
//  FlaneurImagePickerController
//
//  Created by Frenchapp on 24/07/2017.
//  
//

import UIKit
import SafariServices

let kInstagramTokenKey = "kInstagramTokenKey"

struct InstagramAuthInfo {
    let kOAuthURL = "https://api.instagram.com/oauth/authorize/"
    let kMediaURL = "https://api.instagram.com/v1/users/self/media/recent/"
    
    var clientID: String
    var redirectURI: String
    var accessToken: String
}

final class FlaneurImageInstagramProvider: NSObject, FlaneurImageProvider {
    
    var delegate: FlaneurImageProviderDelegate?
    weak var parentVC: UIViewController?

    var instagramAuthInfo: InstagramAuthInfo!

    var permissionCallback: ((Bool) -> Void)?
    
    var nextPageURL: URL?
    
    init(delegate: FlaneurImageProviderDelegate, andParentVC parentVC: UIViewController) {
        guard let infoPlist = Bundle.main.infoDictionary,
              let clientID = infoPlist["InstagramClientID"] as? String,
            let redirectURI = infoPlist["InstagramRedirectURI"] as? String else {
                fatalError("You need to set up: InstagramClientID and InstagramRedirectURI in your info.plist file in order to use instagram source")
        }
        
        self.parentVC = parentVC
        self.instagramAuthInfo = InstagramAuthInfo(clientID: clientID, redirectURI: redirectURI, accessToken: "")
        self.delegate = delegate

        super.init()
    }
    
    func isAuthorized() -> Bool {
        if let token = UserDefaults.standard.string(forKey: kInstagramTokenKey) {
            instagramAuthInfo.accessToken = token
            return true
        }
        return false
    }

    func askForPermission(isPermissionGiven: @escaping (Bool) -> Void) {
        self.permissionCallback = isPermissionGiven
        authenticateUser()
    }

    func fetchImagesFromSource() {
        fetchUserPictures()
    }
}

// MARK: - Instagram Related functions
extension FlaneurImageInstagramProvider: SignInWebViewControllerDelegate {
    
    func createURL(fromBase baseURL: String, withParams params: [String: String]) -> URL? {
        var queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            return nil
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
    
    
    func authenticateUser() {
        guard let url = createURL(fromBase: instagramAuthInfo.kOAuthURL,
                                  withParams: [
                                    "client_id": instagramAuthInfo.clientID,
                                    "redirect_uri": instagramAuthInfo.redirectURI,
                                    "response_type": "token"
            ]) else {
                fatalError("Could not create instagram authentication url with specified params")
        }
        let signInWebView = SignInWebViewController(withURL: url, redirectURI: instagramAuthInfo.redirectURI, andDelegate: self)
        signInWebView.delegate = self
        let nvc = UINavigationController(rootViewController: signInWebView)
        parentVC?.present(nvc, animated: true, completion: nil)
    }
    
    func parseData(data: [String: AnyObject]) {
        // Failure => http code != 200, we present the login view to the user once again, access_token might be dead
        guard let meta = data["meta"],
            let code = meta["code"] as? Int, code == 200 else {
                self.permissionCallback = { [weak self] isAuthenticated in
                    self?.fetchUserPictures()
                }
                self.authenticateUser()
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
        var images = [FlaneurImageDescription]()
        for data in (data["data"] as? [[String: AnyObject]])! {
            guard let dataImages = data["images"] as? [String: AnyObject], (data["type"] as! String) == "image",
                let image = dataImages["standard_resolution"] as? [String: AnyObject],
                let imageURL = image["url"] as? String else {
                    continue
            }
            images.append(FlaneurImageDescription(imageURLString: imageURL)!)
        }
        self.delegate?.didLoadImages(images: images)
    }
    
    func fetchUserPictures(withURL maybeURL: URL? = nil) {
        var url: URL!
        
        if maybeURL == nil {
            url = createURL(fromBase: instagramAuthInfo.kMediaURL, withParams: ["access_token": instagramAuthInfo.accessToken, "count": "30"])
        } else {
            url = maybeURL!
        }
        let task = URLSession.shared.dataTask(with: url!) { [weak self] data, resp, error in
            guard let data = data else {
                self?.delegate?.didFailLoadingImages(with: .instagram)
                return
            }
            do {
                if let dictionaryOK = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    self?.parseData(data: dictionaryOK)
                }
            } catch {
                print(error)
                self?.delegate?.didFailLoadingImages(with: .instagram)
            }
        }
        task.resume()
    }
    
    func fetchNextPage() {
        guard let nextURL = nextPageURL else {
            delegate?.didLoadImages(images: [])
            return
        }
        fetchUserPictures(withURL: nextURL)
    }
    
    func didAuthenticate(withToken token: String) {
        UserDefaults.standard.set(token, forKey: kInstagramTokenKey)
        instagramAuthInfo.accessToken = token
        
        permissionCallback?(true)
        permissionCallback = nil
    }
}



/*
 **  In order to log the user and get the token back from instagram, we need to present a
 **  webview to the user and parse it's return url in the "shouldStartLoadWith" delegate method.
 **
 **  We could have implemented a custom scheme and have presented a SFSafariViewController instead but
 **  it seems that instagram has disabled custom schemes in the return_uri. We can only use "https" scheme.
*/


protocol SignInWebViewControllerDelegate {
    func didAuthenticate(withToken token: String)
}

final class SignInWebViewController: UIViewController, UIWebViewDelegate {
    var webview: UIWebView?
    var url: URL
    var redirectURI: String
    var delegate: SignInWebViewControllerDelegate?

    init(withURL url: URL, redirectURI: String, andDelegate delegate: SignInWebViewControllerDelegate) {
        self.delegate = delegate
        self.url = url
        self.redirectURI = redirectURI
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        webview = UIWebView()
        webview?.delegate = self
        
        self.title = NSLocalizedString("Instagram", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(closeWebView))
        
        let request = URLRequest(url: url)
        webview?.loadRequest(request)
        
        view.addSubview(webview!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        webview?.frame = view.frame
    }
    
    func closeWebView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let urlSring = request.url?.absoluteString {
            if urlSring.contains("token=") {
                delegate?.didAuthenticate(withToken: urlSring.components(separatedBy: "access_token=")[1])
                self.dismiss(animated: true, completion: nil)
            }
        }
        return true
    }
}
