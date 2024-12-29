//
//  APIController.swift
//  reusable_project
//
//  Created by Minhyeok Kim on 2024/05/23.
//

import Foundation

class APIController {
    
    static let shared = APIController()
    
    let baseURL = "rootUrl"
    
    // 각 function 의 endpoint는 rootUrl 뒤의 나머지
    func fetchData<T: Decodable>(endpoint: String, completion: @escaping (T?, Error?) -> Void) {
        let urlString = "\(baseURL)\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data returned", code: 0, userInfo: nil))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                completion(decodedData, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func postData<T: Encodable>(endpoint: String, body: T, completion: @escaping (Error?) -> Void) {
        let urlString = "\(baseURL)\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            completion(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(body)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(error)
                    return
                }
                completion(nil)
            }
            task.resume()
        } catch {
            completion(error)
        }
    }
    
    func deleteData(endpoint: String, completion: @escaping (Error?) -> Void) {
        let urlString = "\(baseURL)\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            completion(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
        task.resume()
    }
}

// Example usage:

//struct MemberModel: Codable {
//    let id: Int
//    let name: String
//    let part: String
//}
//
//// Fetch all members
//APIController.shared.fetchData(endpoint: "") { (members: [MemberModel]?, error) in
//    if let error = error {
//        print("Error fetching members: \(error)")
//    } else if let members = members {
//        print("Fetched members: \(members)")
//        // 이 외의 원하는 동작
//    }
//}
//
//// Fetch members by part
//APIController.shared.fetchData(endpoint: "?part=iOS") { (members: [MemberModel]?, error) in
//    if let error = error {
//        print("Error fetching members by part: \(error)")
//    } else if let members = members {
//        print("Fetched members by part: \(members)")
//        // 이 외의 원하는 동작
//    }
//}
//
//// Fetch member by ID
//APIController.shared.fetchData(endpoint: "/1") { (member: MemberModel?, error) in
//    if let error = error {
//        print("Error fetching member: \(error)")
//    } else if let member = member {
//        print("Fetched member: \(member)")
//        // 이 외의 원하는 동작
//    }
//}
//
//// Post new member
//let newMember = MemberModel(id: 123, name: "John Doe", part: "Engineering")
//APIController.shared.postData(endpoint: "", body: newMember) { error in
//    if let error = error {
//        print("Error posting member: \(error)")
//    } else {
//        print("Member posted successfully")
//        // 이 외의 원하는 동작
//    }
//}
//
//// Delete member by ID
//APIController.shared.deleteData(endpoint: "/1") { error in
//    if let error = error {
//        print("Error deleting member: \(error)")
//    } else {
//        print("Member deleted successfully")
//        // 이 외의 원하는 동작
//    }
//}
