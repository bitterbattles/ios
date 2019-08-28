import UIKit

class BattlesTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    public var spinner: Spinner?
    public var alert: Alert?
    public var id: String?
    public var votesFor: Int?
    public var votesAgainst: Int?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var votesForLabel: UILabel!
    @IBOutlet weak var votesAgainstLabel: UILabel!
    @IBOutlet weak var voteForButton: UIButton!
    @IBOutlet weak var voteAgainstButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func voteFor(_ sender: Any) {
        vote(isVoteFor: true)
    }
    
    @IBAction func voteAgainst(_ sender: Any) {
        vote(isVoteFor: false)
    }
    
    // MARK: Private methods
    
    func vote(isVoteFor: Bool) {
        if API.instance.isLoggedIn() {
            let battleID = self.id ?? ""
            self.spinner!.start()
            API.instance.vote(battleID: battleID, isVoteFor: isVoteFor) { errorCode in
                if errorCode == ErrorCode.none {
                    if isVoteFor {
                        let votes = (self.votesFor ?? 0) + 1
                        self.votesFor = votes
                        self.votesForLabel.text = String(votes)
                    } else {
                        let votes = (self.votesAgainst ?? 0) + 1
                        self.votesAgainst = votes
                        self.votesAgainstLabel.text = String(votes)
                    }
                    self.voteForButton.isHidden = true
                    self.voteAgainstButton.isHidden = true
                    self.votesForLabel.isHidden = false
                    self.votesAgainstLabel.isHidden = false
                }
                self.spinner!.stop() {
                    if errorCode != ErrorCode.none {
                        self.alert!.error("Failed to record vote.")
                    }
                }
            }
        }
    }
    
}