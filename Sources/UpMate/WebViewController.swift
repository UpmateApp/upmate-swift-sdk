import WebKit
import Foundation
import UIKit

class FadeInTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("FadeInTransitioningDelegate: Presenting view controller.")
        return FadeInAnimator(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("FadeInTransitioningDelegate: Dismissing view controller.")
        return FadeInAnimator(isPresenting: false)
    }
}

class FadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
        print("FadeInAnimator initialized with isPresenting: \(isPresenting)")
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        print("FadeInAnimator: Transition duration requested.")
        return 0.3 // Duration of the animation
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        print("FadeInAnimator: Starting animation.")
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else {
            print("FadeInAnimator: Failed to get 'to' view.")
            return
        }
        let duration = transitionDuration(using: transitionContext)
        
        if isPresenting {
            print("FadeInAnimator: Performing fade-in animation.")
            toView.alpha = 0
            containerView.addSubview(toView)
            UIView.animate(withDuration: duration, animations: {
                toView.alpha = 1
            }) { finished in
                print("FadeInAnimator: Fade-in animation completed. Success: \(finished)")
                transitionContext.completeTransition(finished)
            }
        } else {
            print("FadeInAnimator: Performing fade-out animation.")
            UIView.animate(withDuration: duration, animations: {
                toView.alpha = 0
            }) { finished in
                print("FadeInAnimator: Fade-out animation completed. Success: \(finished)")
                toView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            }
        }
    }
}


class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    
    private var webView: WKWebView!
    private var url: URL
    private var presentationStyle: UIModalPresentationStyle
    public var onLoadCompletion: (() -> Void)? // Changed from private to public
    
    init(url: URL, presentationStyle: String) {
        self.url = url
        
        if let style = UIModalPresentationStyle(string: presentationStyle) {
            self.presentationStyle = style
            print("WebViewController initialized with presentation style: \(style)")
        } else {
            print("Invalid presentation style string: \(presentationStyle). Falling back to default.")
            self.presentationStyle = .fullScreen // or another default style
        }
        super.init(nibName: nil, bundle: nil)
        DispatchQueue.main.async {
            print("WebViewController: Setting up WKWebView.")
            
            let webConfiguration = WKWebViewConfiguration()
            let userContentController = WKUserContentController()
            
            // Add the message handler
            userContentController.add(self, name: "closeWebView")
            print("WebViewController: Added message handler 'closeWebView'.")
            
            webConfiguration.userContentController = userContentController
            
            // Initialize the web view with the configuration
            self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
            self.webView.navigationDelegate = self  // Set the navigation delegate
            print("WebViewController: WKWebView initialized.")
            
            self.webView.isOpaque = false
            self.webView.backgroundColor = UIColor.clear
            self.webView.scrollView.bounces = false
            // Load the URL
            let request = URLRequest(url: self.url)
            self.webView.load(request)
            print("WebViewController: Loaded URL: \(self.url.absoluteString)")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WebViewController: viewDidLoad called.")
        
        // Set the web view's frame to match the view controller's view bounds
        webView.frame = self.view.bounds
        view.addSubview(webView)
        print("WebViewController: WKWebView added to view.")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = self.view.bounds
        print("WebViewController: viewDidLayoutSubviews called. Updated webView frame.")
    }
    
    // Handle JavaScript messages
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("WebViewController: Received JavaScript message: \(message.name)")
        if message.name == "closeWebView" {
            print("WebViewController: Closing web view as per JavaScript message.")
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("WebViewController: Content started arriving.")
    }
    
    // WKNavigationDelegate method to detect when the page finishes loading
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebViewController: Page finished loading.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.modalPresentationStyle = self.presentationStyle
            
            let fadeInTransitioningDelegate = FadeInTransitioningDelegate()
            self.transitioningDelegate = fadeInTransitioningDelegate
            if self.presentationStyle == .overCurrentContext {
                self.modalPresentationStyle = .custom
            }
            
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
               let rootVC = keyWindow.rootViewController {
                print("WebViewController: Presenting WebViewController with fade-in transition.")
                rootVC.present(self, animated: true, completion: {
                    print("WebViewController: Presentation completed.")
                    self.onLoadCompletion?()
                })
            } else {
                print("WebViewController: Failed to find key window or root view controller.")
            }
        }
    }
    
    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "closeWebView")
        print("WebViewController: deinit called. Removed script message handler.")
    }
    
    // WKNavigationDelegate method to handle deep links dynamically
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            print("WebViewController: Deciding policy for navigation to URL: \(url.absoluteString)")
            if shouldOpenExternally(url) {
                print("WebViewController: Opening URL externally: \(url.absoluteString)")
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    // Function to determine if the URL should be handled externally
    private func shouldOpenExternally(_ url: URL) -> Bool {
        let externalSchemes = ["http", "https"] // Add any other schemes you want to handle externally
        let shouldOpen = !externalSchemes.contains(url.scheme?.lowercased() ?? "")
        print("WebViewController: shouldOpenExternally determined as \(shouldOpen) for URL: \(url.absoluteString)")
        return shouldOpen
    }
}

extension UIModalPresentationStyle {
    init?(string: String) {
        switch string.lowercased() {
        case "fullScreen".lowercased():
            self = .fullScreen
        case "pageSheet".lowercased():
            self = .pageSheet
        case "formSheet".lowercased():
            self = .formSheet
        case "currentContext".lowercased():
            self = .currentContext
        case "custom".lowercased():
            self = .custom
        case "overFullScreen".lowercased():
            self = .overFullScreen
        case "overCurrentContext".lowercased():
            self = .overCurrentContext
        case "popover".lowercased():
            self = .popover
        case "none".lowercased():
            self = .none
        default:
            print("UIModalPresentationStyle: Invalid presentation style string: \(string)")
            return nil
        }
        print("UIModalPresentationStyle: Initialized with string: \(string)")
    }
}
