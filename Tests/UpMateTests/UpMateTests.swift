@testable import UpMate
import KeychainAccess
import XCTest

class UpMateTests: XCTestCase {
    
    
    var upMate: UpMate!
    var keychain: Keychain!
    
    override func setUpWithError() throws {
        super.setUp()
        // Set up before each test method is called
        keychain = Keychain(service: "test.bundle.identifier")
        upMate = UpMate(apiKey: "testApiKey")
    }
    
    override func tearDownWithError() throws {
        // Clean up after each test method is called
        try keychain.removeAll()
        upMate = nil
        super.tearDown()
    }
    
    
    
    func testInitialization() {
        // Test initial state
        XCTAssertNotNil(upMate, "UpMate should not be nil")
        XCTAssertEqual(upMate.apiKey, "testApiKey", "API key should match")
        XCTAssertNil(upMate.userId, "userId should initially be nil")
        XCTAssertNil(upMate.updateUrl, "updateUrl should initially be nil")
    }
    
    func testStoreUserIdInKeychain() {
        let testUserId = "testUserId"
        upMate.storeUserIdInKeychain(testUserId)
        
        XCTAssertEqual(keychain["userId"], testUserId, "Stored userId should match the test value")
    }
    
    func testFetchUserId() {
        // Mock the network request and response
        let expectation = self.expectation(description: "Fetch User ID")
        upMate.fetchUserId(apiKey: "testApiKey")
        
        // Simulate the completion handler call with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Assuming that fetchUserId sets userId to "testUserId" in its completion handler
            XCTAssertEqual(self.upMate.userId, "testUserId", "User ID should be fetched and set correctly")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testUpdateLastSeenVersion() {
        let currentVersion = "1.0.0" // Mock current version
        Bundle.main.setValue(currentVersion, forKey: "CFBundleShortVersionString")
        upMate.updateLastSeenVersion()
        
        XCTAssertEqual(keychain["lastSeenVersion"], currentVersion, "Last seen version should be updated correctly")
    }
    
    // Add more tests as needed for other methods
}
