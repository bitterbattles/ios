import UIKit

class BattlesTableViewController: UITableViewController  {
    
    // MARK: Properties
    
    @IBOutlet weak var sortControl: UISegmentedControl!
    var spinner: Spinner?
    var alert: Alert?
    var yesNo: YesNo?
    var enableDelete = false
    var battles = [Battle]()
    var listType = "global"
    var currentSort = "recent"
    var currentPage = 1
    let pageSize = 25
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.listType == "myVotes" {
            self.sortControl.isHidden = true
        }
        self.refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl!)
        self.refreshControl!.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)
        self.spinner = Spinner(self)
        self.alert = Alert(self)
        self.yesNo = YesNo(self)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoginChanged(_:)), name: NSNotification.Name(rawValue: "loggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoginChanged(_:)), name: NSNotification.Name(rawValue: "loggedOut"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.battles.count == 0 {
            self.getBattles(resetData: true, showSpinner: true)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BattlesTableViewCell else {
            fatalError("The dequeued cell is not an instance of BattleTableViewCell.")
        }
        let index = indexPath.row
        let nearEnd = (index > (self.battles.count * 3) / 4)
        let hasMore = (self.battles.count == self.currentPage * self.pageSize)
        if nearEnd && hasMore {
            self.currentPage += 1
            self.getBattles(resetData: false, showSpinner: false)
        }
        let battle = self.battles[index]
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
        let hideVoteButtons = (isLoggedIn && !battle.canVote)
        cell.voteForButton.isHidden = hideVoteButtons
        cell.voteAgainstButton.isHidden = hideVoteButtons
        cell.votesForLabel.isHidden = !hideVoteButtons
        cell.votesAgainstLabel.isHidden = !hideVoteButtons
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if enableDelete {
            return .delete
        }
        return .none
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.yesNo!.show(title: "Confirm", message: "Are you sure you want to delete this Battle?") {
                uiAction in
                if uiAction.style == .default {
                    self.spinner!.start()
                    let cell = self.tableView.cellForRow(at: indexPath) as! BattlesTableViewCell
                    API.instance.deleteMyBattle(battleId: cell.id!) {
                        errorCode in
                        self.spinner!.stop() {
                            self.battles.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func vote(_ sender: Any) {
        if !API.instance.isLoggedIn() {
            self.performSegue(withIdentifier: "logInSegue", sender: self)
        }
    }
    
    @IBAction func changeSort(_ sender: Any) {
        switch self.sortControl.selectedSegmentIndex {
        case 1:
            self.currentSort = "popular"
        case 2:
            self.currentSort = "controversial"
        default:
            self.currentSort = "recent"
        }
        self.getBattles(resetData: true, showSpinner: true)
    }
    
    // MARK: Notifications
    
    @objc func onRefresh(_ sender: Any) {
        self.getBattles(resetData: true, showSpinner: false)
    }
    
    @objc func onLoginChanged(_ notification: Notification) {
        self.currentPage = 1
        self.battles = []
        self.tableView.reloadData()
    }
    
    // MARK: Private methods
    
    func getBattles(resetData: Bool, showSpinner: Bool) {
        if showSpinner {
            self.spinner!.start()
        }
        if resetData {
            self.currentPage = 1
        }
        switch self.listType {
        case "myBattles":
            API.instance.getMyBattles(sort: self.currentSort, page: self.currentPage, pageSize: self.pageSize) { errorCode, battles in
                self.handleBattles(errorCode: errorCode, battles: battles, resetData: resetData, showSpinner: showSpinner)
            }
        case "myVotes":
            API.instance.getMyVotes(page: self.currentPage, pageSize: self.pageSize) { errorCode, battles in
                self.handleBattles(errorCode: errorCode, battles: battles, resetData: resetData, showSpinner: showSpinner)
            }
        default:
            API.instance.getBattlesGlobal(sort: self.currentSort, page: self.currentPage, pageSize: self.pageSize) { errorCode, battles in
                self.handleBattles(errorCode: errorCode, battles: battles, resetData: resetData, showSpinner: showSpinner)
            }
        }
    }
    
    func handleBattles(errorCode: ErrorCode, battles: [Battle], resetData: Bool, showSpinner: Bool) {
        if resetData {
            self.battles = battles
        } else {
            self.battles.append(contentsOf: battles)
        }
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
        if showSpinner {
            self.spinner!.stop() {
                if errorCode != ErrorCode.none {
                    self.alert!.error("Failed to load Battles.")
                }
            }
        }
    }
    
    func toDate(unixTime: Int64) -> String {
        return String(unixTime) // TODO
    }
    
}
