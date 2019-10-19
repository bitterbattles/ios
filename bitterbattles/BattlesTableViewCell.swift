import UIKit

class BattlesTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var voteForButton: UIButton!
    @IBOutlet weak var votesForLabel: UILabel!
    @IBOutlet weak var verdictLabel: UILabel!
    @IBOutlet weak var voteAgainstButton: UIButton!
    @IBOutlet weak var votesAgainstLabel: UILabel!
    
    public var spinner: Spinner?
    public var alert: Alert?
    public var battle: Battle?
    
    // MARK: Actions
    
    @IBAction func voteFor(_ sender: Any) {
        self.vote(isVoteFor: true)
    }
    
    @IBAction func voteAgainst(_ sender: Any) {
        self.vote(isVoteFor: false)
    }
    
    // MARK: Public methods
    
    public func updateUI(_ battle: Battle) {
        self.battle = battle
        self.authorLabel.text = String(format: "%@ ago by %@", self.getDeltaTime(self.battle!.createdOn), self.battle!.username)
        self.commentsLabel.text = String(format: "%d comments", self.battle!.comments)
        self.setAndSizeLabel(self.titleLabel, text: self.battle!.title)
        self.setAndSizeLabel(self.descriptionLabel, text: self.battle!.description)
        self.verdictLabel.text = self.getVerdictText(self.battle!.verdict)
        self.updateVotesUI()
    }
    
    // MARK: Private methods
    
    private func getDeltaTime(_ timestamp: Int64) -> String {
        let now = Int64(Date().timeIntervalSince1970)
        let deltaSeconds = now - timestamp
        if deltaSeconds < 60 {
            return String(format: "%d seconds", deltaSeconds)
        } else if deltaSeconds < 3600 {
            let deltaMinutes = deltaSeconds / 60
            return String(format: "%d minutes", deltaMinutes)
        } else if deltaSeconds < 86400 {
            let deltaHours = deltaSeconds / 3600
            return String(format: "%d hours", deltaHours)
        } else if deltaSeconds < 604800 {
            let deltaDays = deltaSeconds / 86400
            return String(format: "%d days", deltaDays)
        } else {
            let deltaWeeks = deltaSeconds / 604800
            return String(format: "%d weeks", deltaWeeks)
        }
    }
    
    private func setAndSizeLabel(_ label: UILabel, text: String) {
        label.text = text
        label.numberOfLines = 0
        label.sizeToFit()
    }
    
    private func getVerdictText(_ verdict: Verdict) -> String {
        switch verdict {
        case .forWins:
            return "<-- Winner!"
        case .againstWins:
            return "Winner! -->"
        case .noDecision:
            return "Too close to call!"
        default:
            return ""
        }
    }
    
    private func updateVotesUI() {
        let votesFor = self.battle!.votesFor
        let votesAgainst = self.battle!.votesAgainst
        let total = votesFor + votesAgainst
        var percentFor = 0
        var percentAgainst = 0
        if total > 0 {
            percentFor = votesFor * 100 / total
            percentAgainst = votesAgainst * 100 / total
        }
        self.votesForLabel.text = String(format: "%d%% agree", percentFor)
        self.votesAgainstLabel.text = String(format: "%d%% disagree", percentAgainst)
        let showResults = (API.instance.isLoggedIn() && !self.battle!.canVote)
        self.voteForButton.isHidden = showResults
        self.voteAgainstButton.isHidden = showResults
        self.votesForLabel.isHidden = !showResults
        self.votesAgainstLabel.isHidden = !showResults
        self.verdictLabel.isHidden = !showResults
    }
    
    private func vote(isVoteFor: Bool) {
        if !API.instance.isLoggedIn() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "loginNeeded"), object: nil)
            return
        }
        let battleID = self.battle!.id
        self.spinner!.start()
        API.instance.vote(battleID: battleID, isVoteFor: isVoteFor) { errorCode in
            if errorCode == ErrorCode.none {
                if isVoteFor {
                    self.battle!.votesFor += 1
                } else {
                    self.battle!.votesAgainst += 1
                }
                self.updateVotesUI()
            }
            self.spinner!.stop() {
                if errorCode != ErrorCode.none {
                    self.alert!.error("Failed to record vote.")
                }
            }
        }
    }
    
}
