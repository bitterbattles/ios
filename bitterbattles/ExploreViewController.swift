import UIKit

class ExploreViewController: UITableViewController  {
    
    // MARK: Properties
    
    @IBOutlet weak var sortControl: UISegmentedControl!
    var spinner: Spinner?
    var alert: Alert?
    var battles = [Battle]()
    var currentSort = "recent"
    var isFirstAppearance = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner = Spinner(self)
        self.alert = Alert(self)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(_:)), name: NSNotification.Name(rawValue: "loggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(_:)), name: NSNotification.Name(rawValue: "loggedOut"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(_:)), name: NSNotification.Name(rawValue: "battlePosted"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isFirstAppearance {
            self.getBattles(true)
            self.isFirstAppearance = false
        }
    }
    
    // MARK: Table view data
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.battles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ExploreTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ExploreTableViewCell else {
            fatalError("The dequeued cell is not an instance of BattleTableViewCell.")
        }
        let battle = self.battles[indexPath.row]
        cell.spinner = self.spinner
        cell.alert = self.alert
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
    
    @IBAction func vote(_ sender: Any) {
        if !API.instance.isLoggedIn() {
            self.performSegue(withIdentifier: "logInSegue", sender: self)
        }
    }
    
    @IBAction func changeSort(_ sender: Any) {
        switch self.sortControl.selectedSegmentIndex {
        case 0:
            self.currentSort = "recent"
        case 1:
            self.currentSort = "popular"
        case 2:
            self.currentSort = "controversial"
        default:
            self.currentSort = "recent"
        }
        self.getBattles(true)
    }
    
    // MARK: Notifications
    
    @objc func onNotification(_ notification: Notification) {
        self.getBattles(false)
    }
    
    // MARK: Private methods
    
    func getBattles(_ showSpinner: Bool) {
        if showSpinner {
            self.spinner!.start()
        }
        API.instance.getBattles(sort: self.currentSort, page: 1, pageSize: 25) { errorCode, battles in
            self.battles = battles
            self.tableView.reloadData()
            if showSpinner {
                self.spinner!.stop() {
                    if errorCode != ErrorCode.none {
                        self.alert!.error("Failed to load Battles.")
                    }
                }
            }
        }
    }
    
    func toDate(unixTime: Int64) -> String {
        return String(unixTime) // TODO
    }
    
}
