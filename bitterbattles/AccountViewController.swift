import UIKit

class AccountViewController: UITableViewController {
    
    // MARK: Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? BattlesTableViewController,
            let index = self.tableView.indexPathForSelectedRow?.row
            else {
                return
        }
        switch index {
        case 1:
            viewController.listType = "myVotes"
        default:
            viewController.listType = "myBattles"
            viewController.enableDelete = true
        }
    }
    
    // MARK: Actions

    @IBAction func logOut(_ sender: Any) {
        API.instance.logOut(sendNotification: true)
    }
    
}
