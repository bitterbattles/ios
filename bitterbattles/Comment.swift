class Comment {
    
    // MARK: Properties
    
    var id: String
    var battleId: String
    var createdOn: Int64
    var username: String
    var comment: String
    
    // MARK: Initialization
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.battleId = data["battleId"] as? String ?? ""
        self.createdOn = data["createdOn"] as? Int64 ?? 0
        self.username = data["username"] as? String ?? ""
        self.comment = data["comment"] as? String ?? ""
    }
    
}
