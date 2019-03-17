import UIKit

class Battle {
    
    // MARK: Properties
    
    var id: String
    var username: String
    var title: String
    var description: String
    var hasVoted: Bool
    var votesFor: Int
    var votesAgainst: Int
    var createdOn: Int64
    
    // MARK: Initialization
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.hasVoted = data["hasVoted"] as? Bool ?? false
        self.votesFor = data["votesFor"] as? Int ?? 0
        self.votesAgainst = data["votesAgainst"] as? Int ?? 0
        self.createdOn = data["createdOn"] as? Int64 ?? 0
    }
    
}
