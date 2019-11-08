import UIKit

class CommentsTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    // MARK: Public methods
    
    public func updateUI(_ comment: Comment) {
        self.authorLabel.text = String(format: "%@ ago by %@", self.getDeltaTime(comment.createdOn), comment.username)
        self.commentLabel.text = comment.comment
        self.commentLabel.numberOfLines = 0
        self.commentLabel.sizeToFit()
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

}
