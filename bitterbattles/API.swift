import Foundation

class API {
    
    // MARK: Properties
    
    static let instance = API()
    var accessToken: String
    
    // MARK: Initialization
    
    private init() {
        self.accessToken = UserDefaults.standard.string(forKey: "accessToken") ?? ""
    }
    
    // MARK: Public methods
    
    public func isLoggedIn() -> Bool {
        return accessToken != ""
    }
    
    public func getBattles(sort: String, page: Int, pageSize: Int, completion: @escaping (ErrorCode, [Battle]) -> Void) {
        let uri = "battles?sort=\(sort)&page=\(page)&pageSize=\(pageSize)"
        request(method: "GET", uri: uri, body: [:], completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            let errorCode = self.getErrorCode(error: error, response: response, data: data)
            if errorCode != ErrorCode.none {
                completion(errorCode, [])
            }
            var battles :[Battle] = []
            if data != nil, let results = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                for case let result in results ?? [] {
                    battles.append(Battle(data: result))
                }
            }
            completion(ErrorCode.none, battles)
        })
    }
    
    public func signUp(username: String, password: String, completion: @escaping (ErrorCode) -> Void) {
        var data = [String: Any]()
        data["username"] = username
        data["password"] = password
        request(method: "POST", uri: "users", body: data, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            completion(self.getErrorCode(error: error, response: response, data: data))
        })
    }
    
    public func logIn(username: String, password: String, completion: @escaping (ErrorCode) -> Void) {
        var data = [String: Any]()
        data["username"] = username
        data["password"] = password
        request(method: "POST", uri: "logins", body: data, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            let errorCode = self.getErrorCode(error: error, response: response, data: data)
            if errorCode == ErrorCode.none {
                if data != nil, let result = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    self.setAccessToken(value: result?["accessToken"] as? String ?? "")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loggedIn"), object: nil)
                }
            }
            completion(errorCode)
        })
    }
    
    public func logOut() {
        self.setAccessToken(value: "")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "loggedOut"), object: nil)
    }
    
    public func postBattle(title: String, description: String, completion: @escaping (ErrorCode) -> Void) {
        var data = [String: Any]()
        data["title"] = title
        data["description"] = description
        request(method: "POST", uri: "battles", body: data, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            completion(self.getErrorCode(error: error, response: response, data: data))
        })
    }
    
    public func vote(battleID: String, isVoteFor: Bool, completion: @escaping (ErrorCode) -> Void) {
        var data = [String: Any]()
        data["battleId"] = battleID
        data["isVoteFor"] = isVoteFor
        request(method: "POST", uri: "votes", body: data, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            completion(self.getErrorCode(error: error, response: response, data: data))
        })
    }
    
    // MARK: Private methods
    
    func request(method: String, uri: String, body: [String: Any], completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let url = URL(string: "https://api-dev.bitterbattles.com/v1/\(uri)")!
        var request = URLRequest(url: url)
        request.httpMethod = method
        if self.accessToken != "" {
            request.addValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        }
        if body.count > 0 {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func getErrorCode(error: Error?, response: URLResponse?, data: Data?) -> ErrorCode {
        if error != nil {
            return ErrorCode.unknown
        }
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                return ErrorCode.none
            }
        }
        if data != nil, let result = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
            if let errorCode = result?["errorCode"] as? Int {
                return ErrorCode(rawValue: errorCode) ?? ErrorCode.unknown
            }
        }
        return ErrorCode.unknown
    }
    
    func setAccessToken(value: String) {
        self.accessToken = value
        UserDefaults.standard.set(value, forKey: "accessToken")
    }
    
}
