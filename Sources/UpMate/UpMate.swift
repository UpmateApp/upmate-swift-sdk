import Foundation
import WebKit
import UIKit
import KeychainAccess

public class UpMate {
    
    internal var apiKey: String
    internal let keychain: Keychain
    var userId: String? // `internal(set)` allows reading outside but setting only inside
    internal var lastSeenVersion: String? // `internal(set)` allows reading outside but setting only inside
    internal var currentVersion: String? // `internal(set)` allows reading outside but setting only inside
    var updateUrl: String? // `internal(set)` allows reading outside but setting only inside
    var presentationStyle: String? // `internal(set)` allows reading outside but setting only inside
    
    
    internal let userIdKey = "userId"
    internal let lastSeenVersionKey = "lastSeenVersion"
    internal let hasSeenVersionUpdate = "hasSeenVersionUpdate"
    
    public init(apiKey: String) {
        self.apiKey = apiKey
        self.keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "default.bundle.identifier")
        
        self.lastSeenVersion = keychain[lastSeenVersionKey]
        initializeUserId()
        updateLastSeenVersion()
        print("UpMate SDK initialized with API key: \(apiKey)")
    }
    
    private func getUpdates(version: String, completion: @escaping (Bool) -> Void) {
        print("Fetching updates for version: \(version)")
        getUpdatesNetwork(apiKey: apiKey, appVersion: version) { result in
            switch result {
            case .success(let updateResponse):
                if let url = updateResponse?.url, let presentationStyle = updateResponse?.presentationStyle {
                    self.updateUrl = url
                    self.presentationStyle = presentationStyle
                    print("Update available with URL: \(url) and presentation style: \(presentationStyle)")
                    completion(true) // Indicate success
                } else {
                    print("No updates available for the current version")
                    completion(false) // Indicate no updates
                }
            case .failure(let error):
                print("Failed to get updates: \(error.localizedDescription)")
                completion(false) // Indicate failure
            }
        }
    }
    
    private func initializeUserId() {
        if let storedUserId = keychain[userIdKey] {
            // If userId exists in Keychain, use it and update lastSeenVersion
            self.userId = storedUserId
            print("Fetched userId from Keychain: \(storedUserId)")
        } else {
            // Fetch userId from API if not in Keychain
            print("UserId not found in Keychain. Fetching from API.")
            fetchUserId(apiKey: apiKey)
        }
    }
    
    internal func fetchUserId(apiKey: String) {
        print("Fetching userId using API key: \(apiKey)")
        getUserByApiKey(apiKey: apiKey) { [weak self] result in
            switch result {
            case .success(let userData):
                self?.userId = userData.userId
                self?.storeUserIdInKeychain(userData.userId)
                print("User ID fetched and set in UpMate: \(userData.userId)")
            case .failure(let error):
                print("Failed to fetch user ID: \(error.localizedDescription)")
            }
        }
    }
    
    internal func storeUserIdInKeychain(_ userId: String) {
        do {
            try keychain.set(userId, key: userIdKey)
            print("Stored userId in Keychain: \(userId)")
        } catch let error {
            print("Error storing userId in Keychain: \(error.localizedDescription)")
        }
    }
    
    
    internal func updateLastSeenVersion() {
        self.currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        print("Current app version: \(self.currentVersion ?? "unknown")")
        
        if self.currentVersion != keychain[lastSeenVersionKey] {
            self.setHasSeenVersionUpdate(value: false)
        }
        
        do {
            try keychain.set(currentVersion ?? "no-version", key: lastSeenVersionKey)
            print("Updated lastSeenVersion in Keychain to: \(currentVersion ?? "no-version")")
        } catch let error {
            print("Error updating lastSeenVersion in Keychain: \(error.localizedDescription)")
        }
    }
    
    internal func setHasSeenVersionUpdate(value: Bool) {
        let strValue = String(value)
        do {
            try keychain.set(strValue, key: hasSeenVersionUpdate)
            print("Updated hasSeenVersionUpdate in Keychain to: \(strValue)")
        } catch let error {
            print("Error updating hasSeenVersionUpdate in Keychain: \(error.localizedDescription)")
        }
    }
    
    public func displayLastUpdateAlways() {
        print("displayLastUpdateAlways called")
        getUpdates(version: self.currentVersion ?? "") { success in
            // Update last seen version regardless of success or failure
            self.updateLastSeenVersion()
            
            guard success, let url = self.updateUrl, let presentationStyle = self.presentationStyle else {
                print("No update to display.")
                return
            }
            
            print("Displaying update from URL: \(url)")
            self.presentWebView(with: url, presentationStyle: presentationStyle)
        }
    }
    
    public func displayLastUpdateIfNeeded() {
        print("displayLastUpdateIfNeeded called")
        getUpdates(version: self.currentVersion ?? "") { success in
            // Update last seen version regardless of success or failure
            self.updateLastSeenVersion()
            
            guard success, let url = self.updateUrl, let presentationStyle = self.presentationStyle else {
                print("No update needed.")
                return
            }
            
            if self.keychain[self.hasSeenVersionUpdate] == "false" {
                print("Displaying update from URL: \(url)")
                self.presentWebView(with: url, presentationStyle: presentationStyle)
            } else {
                print("User has already seen this update.")
            }
        }
    }
    
    
    public func presentWebView(with urlString: String, toast: Bool = false, presentationStyle: String = "formSheet") {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        DispatchQueue.main.async {
            // Initialize the WebViewController without the completion handler first
            let webViewVC = WebViewController(url: url, presentationStyle: presentationStyle)
            print("WebView presented with URL: \(urlString)")
            self.setHasSeenVersionUpdate(value: true)
        }
    }
}

extension WKWebView {
    override open var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
