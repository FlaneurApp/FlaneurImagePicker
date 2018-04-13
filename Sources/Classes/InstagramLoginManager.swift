import SafariServices

public extension NSNotification.Name {
    static let InstagramAPIAccessTokenDidChange = NSNotification.Name("com.flaneurapp.flaneurimagepicker.InstagramAPIAccessTokenDidChange")
}

/// An Instagram API wrapper for authorization.
///
/// Beware, Instagram announced this API won't work from early 2020.s
public class InstagramLoginManager {
    private let instagramBaseURL = URL(string: "https://api.instagram.com")!

    static let kInstagramTokenKey = "kInstagramTokenKey"

    /// The client ID provided by Instagram (cf. https://www.instagram.com/developer/clients/manage/)
    let clientID: String

    /// The redirect URI you set up on Instagram Developer console.
    let redirectURI: String

    /// The access token fetched by the manager after successful authorization.
    var accessToken: String?

    /// The completion handler that gets called once authorization succeeded or failed.
    var authorizationCompletionHandler: ((Bool) -> Void) = { _ in }

    public init(clientID: String, redirectURI: String) {
        self.clientID = clientID
        self.redirectURI = redirectURI
    }

    static public var currentAccessToken: String? {
        return UserDefaults.standard.string(forKey: kInstagramTokenKey)
    }

    var authorizationURL: URL {
        var authURLComponents = URLComponents()
        authURLComponents.path = "/oauth/authorize/"
        authURLComponents.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "token")
        ]

        guard let authURL = authURLComponents.url(relativeTo: instagramBaseURL) else {
            fatalError("Couldn't build auth URL")
        }

        return authURL
    }

    func mediaURL(count: Int = 30) -> URL? {
        guard let accessToken = accessToken else { return nil }

        var authURLComponents = URLComponents()
        authURLComponents.path = "/v1/users/self/media/recent/"
        authURLComponents.queryItems = [
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "count", value: String(count))
        ]

        guard let authURL = authURLComponents.url(relativeTo: instagramBaseURL) else {
            fatalError("Couldn't build auth URL")
        }

        return authURL
    }

    public func authenticate(from presentingViewController: UIViewController,
                      completionHandler: @escaping (Bool) -> Void) {
        authorizationCompletionHandler = completionHandler
        if #available(iOS 11.0, *) {
            let session = ModernAuthenticationSession()
            session.delegate = self
            session.authenticate(authURL: authorizationURL)
        } else {
            let session = LegacyAuthenticationSession()
            session.delegate = self
            session.authenticate(from: presentingViewController,
                                 authURL: authorizationURL,
                                 redirectURI: redirectURI)
        }
    }
}

extension InstagramLoginManager: InstagramAuthenticationSessionDelegate {
    func didFetchURLWithAccessToken(url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let accessTokenSubstrings = components?.fragment?.split(separator: "="),
            accessTokenSubstrings.count == 2 && accessTokenSubstrings[0] == "access_token" {
            let newAccessToken = String(accessTokenSubstrings[1])
            self.accessToken = newAccessToken

            // Store and Send notification
            UserDefaults.standard.set(newAccessToken, forKey: InstagramLoginManager.kInstagramTokenKey)
            NotificationCenter.default.post(Notification(name: NSNotification.Name.InstagramAPIAccessTokenDidChange, object: accessToken, userInfo: nil))
            authorizationCompletionHandler(true)
        } else {
            authorizationCompletionHandler(false)
        }
    }

    func didFail(error: Error) {
        print("ERROR")
        authorizationCompletionHandler(false)
    }
}

protocol InstagramAuthenticationSessionDelegate: AnyObject {
    func didFetchURLWithAccessToken(url: URL)
    func didFail(error: Error)
}

@available(iOS 11.0, *)
class ModernAuthenticationSession {
    var authSession: SFAuthenticationSession?
    weak var delegate: InstagramAuthenticationSessionDelegate?

    func authenticate(authURL: URL) {
        // Initialize auth session
        authSession = SFAuthenticationSession(url: authURL,
                                              callbackURLScheme: "flaneur",
                                              completionHandler: authenticationHandler)
        // Kick it off
        authSession?.start()
    }

    private func authenticationHandler(url: URL?, error: Error?) {
        guard let url = url else {
            if let error = error {
                delegate?.didFail(error: error)
            } else {
                print("Error for unknown reasons")
            }
            return
        }

        delegate?.didFetchURLWithAccessToken(url: url)
    }
}

private class LegacyAuthenticationSession {
    weak var delegate: InstagramAuthenticationSessionDelegate?

    func authenticate(from presentingViewController: UIViewController, authURL: URL, redirectURI: String) {
        let signInWebView = SignInWebViewController(url: authURL, redirectURI: redirectURI)
        signInWebView.delegate = delegate
        presentingViewController.present(UINavigationController(rootViewController: signInWebView),
                                         animated: true)
    }

    class SignInWebViewController: UIViewController, UIWebViewDelegate {
        let url: URL
        let redirectURI: String

        let webview = UIWebView()

        weak var delegate: InstagramAuthenticationSessionDelegate?

        init(url: URL, redirectURI: String) {
            self.url = url
            self.redirectURI = redirectURI
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            webview.delegate = self

            self.title = NSLocalizedString("Instagram", comment: "")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(closeWebView))

            webview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(webview)

            NSLayoutConstraint.activate([
                webview.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0.0),
                webview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
                webview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
                webview.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: 0.0)
                ])

            webview.loadRequest(URLRequest(url: url))
        }

        @objc func closeWebView() {
            self.dismiss(animated: true, completion: nil)
        }

        func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            if let url = request.url {
                delegate?.didFetchURLWithAccessToken(url: url)
            } else {
                print("Error for unknown reasons")
            }
            return false
        }
    }
}
