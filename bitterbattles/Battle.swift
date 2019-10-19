class Battle {
    
    // MARK: Properties
    
    var id: String
    var createdOn: Int64
    var username: String
    var title: String
    var description: String
    var canVote: Bool
    var votesFor: Int
    var votesAgainst: Int
    var comments: Int
    var verdict: Verdict
    
    // MARK: Initialization
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.createdOn = data["createdOn"] as? Int64 ?? 0
        self.username = data["username"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.canVote = data["canVote"] as? Bool ?? false
        self.votesFor = data["votesFor"] as? Int ?? 0
        self.votesAgainst = data["votesAgainst"] as? Int ?? 0
        self.comments = data["comments"] as? Int ?? 0
        self.verdict = Verdict(rawValue: data["verdict"] as? Int ?? 0) ?? Verdict.unknown
    }
    
}
