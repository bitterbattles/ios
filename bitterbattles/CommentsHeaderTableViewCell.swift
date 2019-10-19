import UIKit

class CommentsHeaderTableViewCell: UITableViewCell {
    
    // MARK: Actions
    
    @IBAction func post(_ sender: Any) {
        if !API.instance.isLoggedIn() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "loginNeeded"), object: nil)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "postComment"), object: nil)
        }
    }
    
}
