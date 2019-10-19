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
        self.refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl!)
        self.refreshControl!.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)
        self.spinner = Spinner(self)
        self.alert = Alert(self)
        self.yesNo = YesNo(self)
        self.tableView.register(UINib(nibName: "BattlesTableViewCell", bundle: nil), forCellReuseIdentifier: "battle")
        NotificationCenter.default.addObserver(self, selector: #selector(onLoginChanged(_:)), name: NSNotification.Name(rawValue: "loggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoginChanged(_:)), name: NSNotification.Name(rawValue: "loggedOut"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoginNeeded), name: NSNotification.Name(rawValue: "loginNeeded"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "battle", for: indexPath) as! BattlesTableViewCell
        let index = indexPath.row
        let nearEnd = (index > (self.battles.count * 3) / 4)
        let hasMore = (self.battles.count == self.currentPage * self.pageSize)
        if nearEnd && hasMore {
            self.currentPage += 1
            self.getBattles(resetData: false, showSpinner: false)
        }
        cell.spinner = self.spinner
        cell.alert = self.alert
        cell.updateUI(self.battles[index])
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
                    API.instance.deleteMyBattle(battleId: cell.battle!.id) {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "selectBattleSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as? BattleDetailsViewController
        if viewController != nil {
            let index = self.tableView.indexPathForSelectedRow!.row
            viewController!.battleId = self.battles[index].id
        }
    }
    
    // MARK: Actions
    
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
    
    @objc func onLoginNeeded(_ notification: Notification) {
        self.performSegue(withIdentifier: "logInSegue", sender: self)
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
    
}
