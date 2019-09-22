import Foundation

class API {
    
    // MARK: Properties
    
    static let instance = API()
    let expiryThreshold = Int64(60) // seconds
    var accessToken: String
    var accessExpiresOn: Int64
    var refreshToken: String
    var refreshExpiresOn: Int64
    
    // MARK: Initialization
    
    private init() {
        self.accessToken = ""
        self.accessExpiresOn = 0
        self.refreshToken = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
        self.refreshExpiresOn = Int64(UserDefaults.standard.integer(forKey: "refreshExpiresOn"))
    }
    
    // MARK: Public methods
    
    public func isLoggedIn() -> Bool {
        return accessToken != ""
    }
    
    public func refreshLogin(sendNotification: Bool, completion: @escaping () -> Void) {
        if !self.isExpired(token: self.refreshToken, expiresOn: self.refreshExpiresOn) {
            var data = [String: Any]()
            data["refreshToken"] = self.refreshToken
            request(method: "POST", uri: "refreshes", body: data, attemptRefresh: false, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                let errorCode = self.getErrorCode(error: error, response: response, data: data)
                if errorCode == ErrorCode.none {
                    self.handleLogin(data: data, sendNotification: sendNotification)
                } else {
                    self.logOut(sendNotification: sendNotification)
                }
                completion()
            })
        } else {
            self.logOut(sendNotification: sendNotification)
            completion()
        }
    }
    
    public func getBattlesGlobal(sort: String, page: Int, pageSize: Int, completion: @escaping (ErrorCode, [Battle]) -> Void) {
        let uri = "battles?sort=\(sort)&page=\(page)&pageSize=\(pageSize)"
        requestBattles(uri: uri, completion: completion)
    }
    
    public func signUp(username: String, password: String, completion: @escaping (ErrorCode) -> Void) {
        var data = [String: Any]()
        data["username"] = username
        data["password"] = password
        request(method: "POST", uri: "users", body: data, attemptRefresh: false, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            completion(self.getErrorCode(error: error, response: response, data: data))
        })
    }
    
    public func logIn(username: String, password: String, completion: @escaping (ErrorCode) -> Void) {
        var data = [String: Any]()
        data["username"] = username
        data["password"] = password
        request(method: "POST", uri: "logins", body: data, attemptRefresh: false, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            let errorCode = self.getErrorCode(error: error, response: response, data: data)
            if errorCode == ErrorCode.none {
                self.handleLogin(data: data, sendNotification: true)
            }
            completion(errorCode)
        })
    }
    
    public func logOut(sendNotification: Bool) {
        let wasLoggedIn = self.isLoggedIn()
        self.accessToken = ""
        self.accessExpiresOn = 0
        self.refreshToken = ""
        self.refreshExpiresOn = 0
        UserDefaults.standard.set("", forKey: "refreshToken")
        UserDefaults.standard.set(0, forKey: "refreshExpiresOn")
        if wasLoggedIn && sendNotification {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "loggedOut"), object: nil)
        }
    }
    
    public func vote(battleID: String, isVoteFor: Bool, completion: @escaping (ErrorCode) -> Void) {
        var data = [String: Any]()
        data["battleId"] = battleID
        data["isVoteFor"] = isVoteFor
        request(method: "POST", uri: "votes", body: data, attemptRefresh: true, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            completion(self.getErrorCode(error: error, response: response, data: data))
        })
    }
    
    public func postBattle(title: String, description: String, completion: @escaping (ErrorCode) -> Void) {
        var data = [String: Any]()
        data["title"] = title
        data["description"] = description
        request(method: "POST", uri: "battles", body: data, attemptRefresh: true, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            completion(self.getErrorCode(error: error, response: response, data: data))
        })
    }
    
    public func getMyBattles(sort: String, page: Int, pageSize: Int, completion: @escaping (ErrorCode, [Battle]) -> Void) {
        let uri = "users/me/battles?sort=\(sort)&page=\(page)&pageSize=\(pageSize)"
        requestBattles(uri: uri, completion: completion)
    }
    
    public func deleteMyBattle(battleId: String, completion: @escaping (ErrorCode) -> Void) {
        let uri = "users/me/battles/\(battleId)"
        request(method: "DELETE", uri: uri, body: [:], attemptRefresh: true, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            completion(self.getErrorCode(error: error, response: response, data: data))
        })
    }
    
    public func getMyVotes(page: Int, pageSize: Int, completion: @escaping (ErrorCode, [Battle]) -> Void) {
        let uri = "votes/me/battles?page=\(page)&pageSize=\(pageSize)"
        requestBattles(uri: uri, completion: completion)
    }
    
    public func deleteMyAccount(completion: @escaping (ErrorCode) -> Void) {
        let uri = "users/me"
        request(method: "DELETE", uri: uri, body: [:], attemptRefresh: true, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            completion(self.getErrorCode(error: error, response: response, data: data))
        })
    }
    
    // MARK: Private methods
    
    func requestBattles(uri: String, completion: @escaping (ErrorCode, [Battle]) -> Void) {
        request(method: "GET", uri: uri, body: [:], attemptRefresh: true, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
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
    
    func request(method: String, uri: String, body: [String: Any], attemptRefresh: Bool, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let url = URL(string: "https://api-dev.bitterbattles.com/v1/\(uri)")!
        var request = URLRequest(url: url)
        request.httpMethod = method
        if body.count > 0 {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        if self.isExpired(token: self.accessToken, expiresOn: self.accessExpiresOn) && attemptRefresh {
            self.refreshLogin(sendNotification: true) {
                self.request(session: session, request: &request, completionHandler: completionHandler)
            }
        } else {
            self.request(session: session, request: &request, completionHandler: completionHandler)
        }
    }
    
    func request(session: URLSession, request: inout URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if self.accessToken != "" {
            request.addValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
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
    
    func handleLogin(data: Data?, sendNotification: Bool) {
        let wasLoggedIn = self.isLoggedIn()
        if data != nil, let result = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
            let now = self.now()
            self.accessToken = result?["accessToken"] as? String ?? ""
            self.accessExpiresOn = now + (result?["accessExpiresIn"] as? Int64 ?? 0)
            self.refreshToken = result?["refreshToken"] as? String ?? ""
            self.refreshExpiresOn = now + (result?["refreshExpiresIn"] as? Int64 ?? 0)
            UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
            UserDefaults.standard.set(refreshExpiresOn, forKey: "refreshExpiresOn")
        }
        if !wasLoggedIn && self.isLoggedIn() && sendNotification {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "loggedIn"), object: nil)
        }
    }
    
    func isExpired(token: String, expiresOn: Int64) -> Bool {
        return token == "" || expiresOn <= (self.now() + self.expiryThreshold)
    }
    
    func now() -> Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
    
}
