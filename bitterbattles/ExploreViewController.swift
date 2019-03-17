import UIKit

class BattlesViewController: UITableViewController  {
    
    // MARK: Properties
    
    var battles = [Battle]()
    var currentSort = "recent"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.rowHeight = UITableView.automaticDimension
        getBattles()
        NotificationCenter.default.addObserver(self, selector: #selector(onLoginChanged(_:)), name: NSNotification.Name(rawValue: "loggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoginChanged(_:)), name: NSNotification.Name(rawValue: "loggedOut"), object: nil)
    }
    
    // MARK: Table view data
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.battles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BattleTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BattleTableViewCell else {
            fatalError("The dequeued cell is not an instance of BattleTableViewCell.")
        }
        let battle = self.battles[indexPath.row]
        cell.id = battle.id
        cell.votesFor = battle.votesFor
        cell.votesAgainst = battle.votesAgainst
        cell.titleLabel.text = battle.title
        cell.titleLabel.numberOfLines = 0
        cell.titleLabel.sizeToFit()
        cell.createdOnLabel.text = self.toDate(unixTime: battle.createdOn)
        cell.usernameLabel.text = battle.username
        cell.descriptionLabel.text = battle.description
        cell.descriptionLabel.numberOfLines = 0
        cell.descriptionLabel.sizeToFit()
        cell.votesForLabel.text = String(battle.votesFor)
        cell.votesAgainstLabel.text = String(battle.votesAgainst)
        let isLoggedIn = API.instance.isLoggedIn()
        cell.votesForLabel.isHidden = !battle.hasVoted || !isLoggedIn
        cell.votesAgainstLabel.isHidden = !battle.hasVoted || !isLoggedIn
        cell.voteForButton.isHidden = battle.hasVoted
        cell.voteAgainstButton.isHidden = battle.hasVoted
        return cell
    }
    
    // MARK: Actions
    
    @IBAction func loadRecent(_ sender: Any) {
        self.currentSort = "recent"
        getBattles()
    }
    
    @IBAction func loadPopular(_ sender: Any) {
        self.currentSort = "popular"
        getBattles()
    }
    
    @IBAction func loadControversial(_ sender: Any) {
        self.currentSort = "controversial"
        getBattles()
    }
    
    // MARK: Notifications
    
    @objc func onLoginChanged(_ notification: Notification) {
        getBattles()
    }
    
    // MARK: Private methods
    
    func getBattles() {
        // TODO: Start spinner
        API.instance.getBattles(sort: self.currentSort, page: 1, pageSize: 25) { errorCode, battles in
            // TODO: Stop spinner
            if errorCode == ErrorCode.none {
                self.battles = battles
                self.tableView.reloadData()
            } else {
                // TODO: If error, show error message
            }
        }
    }
    
    func toDate(unixTime: Int64) -> String {
        return String(unixTime) // TODO
    }
    
}
