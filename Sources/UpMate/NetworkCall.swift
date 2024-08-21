import Foundation
import UIKit
import WebKit

// Define a struct for the expected user data response, assuming JSON response structure
struct UserData: Codable {
    let userId: String
    // Add other properties based on the expected user data structure
}


// Define a struct for the update response, if applicable
struct UpdateResponse: Codable {
    let url: String
    let presentationStyle: String
}


func updateLastSeenVersion(apiKey: String, lastSeenVersion: String, completion: @escaping (Result<UpdateResponse, Error>) -> Void) {
    // Define the URL of the API endpoint
    guard let url = URL(string: "https://api-6vuago6yaa-uc.a.run.app/update-user-by-api-key") else {
        print("Invalid URL")
        return
    }
    
    // Create a URLRequest and set the method to POST
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Set the API key in the headers
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    
    // Set the content type to JSON
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Prepare the request body with lastSeenVersion
    let requestBody = ["lastSeenVersion": lastSeenVersion]
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch let error {
        print("Error encoding request body: \(error)")
        completion(.failure(error))
        return
    }
    
    // Create a URLSession data task to make the request
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle errors in the request
        if let error = error {
            print("Error making request: \(error)")
            completion(.failure(error))
            return
        }
        
        // Ensure we received a proper response and data
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let data = data else {
            print("Invalid response or data")
            completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: nil)))
            return
        }
        
        do {
            // Decode the response data into the UpdateResponse struct
            let updateResponse = try JSONDecoder().decode(UpdateResponse.self, from: data)
            print("Update response: \(updateResponse)")
            completion(.success(updateResponse))
        } catch let decodingError {
            print("Error decoding response: \(decodingError)")
            completion(.failure(decodingError))
        }
    }
    
    // Start the task
    task.resume()
}


func getUserByApiKey(apiKey: String, completion: @escaping (Result<UserData, Error>) -> Void) {
    // Define the URL of the API endpoint
    guard let url = URL(string: "https://api-6vuago6yaa-uc.a.run.app/get-user-by-api-key") else {
        print("Invalid URL")
        return
    }
    
    // Create a URLRequest and set the method to GET
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    // Set the API key in the headers
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    
    // Create a URLSession data task to make the request
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle errors in the request
        if let error = error {
            print("Error making request: \(error)")
            completion(.failure(error))
            return
        }
        
        // Ensure we received a proper response and data
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let data = data else {
            print("Invalid response or data")
            completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: nil)))
            return
        }
        
        do {
            // Decode the response data into the UserData struct
            let userData = try JSONDecoder().decode(UserData.self, from: data)
            print("User data retrieved: \(userData)")
            completion(.success(userData))
        } catch let decodingError {
            print("Error decoding response: \(decodingError)")
            completion(.failure(decodingError))
        }
    }
    
    // Start the task
    task.resume()
}

// Define a struct for the expected update data response
struct UpdateData: Codable {
    let version: String
    let url: String
    // Add other properties based on the expected update data structure
}


func getUpdatesNetwork(apiKey: String, appVersion: String, completion: @escaping (Result<UpdateResponse?, Error>) -> Void) {
    // Define the URL of the API endpoint
    guard let url = URL(string: "https://api-6vuago6yaa-uc.a.run.app/get-updates?appVersion=\(appVersion)") else {
        print("Invalid URL")
        completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: nil)))
        return
    }
    
    // Create a URLRequest and set the method to GET
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    // Set the API key in the headers
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    
    // Create a URLSession data task to make the request
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle errors in the request
        if let error = error {
            print("Error making request: \(error)")
            completion(.failure(error))
            return
        }
        
        // Ensure we received a proper response and data
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid response format")
            completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: nil)))
            return
        }
        
        if httpResponse.statusCode == 204 {
            // No content, no updates found
            print("No updates found with version greater than appVersion")
            completion(.success(nil))
            return
        }
        
        guard httpResponse.statusCode == 200, let data = data else {
            print("Unexpected response code: \(httpResponse.statusCode)")
            completion(.failure(NSError(domain: "UnexpectedResponse", code: httpResponse.statusCode, userInfo: nil)))
            return
        }
        
        do {
            // Decode the response data into the UpdateResponse struct
            let updateResponse = try JSONDecoder().decode(UpdateResponse.self, from: data)
            print("Update URL retrieved: \(updateResponse.url)")
            print("Update presentationStyle retrieved: \(updateResponse.presentationStyle)")
            completion(.success(updateResponse))
        } catch let decodingError {
            print("Error decoding response: \(decodingError)")
            completion(.failure(decodingError))
        }
    }
    
    // Start the task
    task.resume()
}

