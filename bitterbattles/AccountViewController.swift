import UIKit

class AccountViewController: UIViewController {
    
    // MARK: Actions

    @IBAction func logOut(_ sender: Any) {
        API.instance.logOut()
    }
    
}
