import UIKit

class BattleDetailsViewController: UITableViewController {
    
    // MARK - Properties
    
    var spinner: Spinner?
    var alert: Alert?
    var currentPage = 1
    let pageSize = 25
    var battleId: String?
    var battle: Battle?
    var comments = [Comment]()
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl!)
        self.refreshControl!.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)
        self.spinner = Spinner(self)
        self.alert = Alert(self)
        self.tableView.register(UINib(nibName: "BattlesTableViewCell", bundle: nil), forCellReuseIdentifier: "battle")
        self.tableView.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "comment")
        NotificationCenter.default.addObserver(self, selector: #selector(onPostComment), name: NSNotification.Name(rawValue: "postComment"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.comments.count == 0 {
            self.getData(showSpinner: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as? PostCommentViewController
        if viewController != nil {
            viewController!.battleId = self.battleId!
        }
    }
    
    // MARK: Table view data
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.battle == nil {
            return 0
        } else {
            return self.comments.count + 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        if index == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "battle", for: indexPath) as! BattlesTableViewCell
            cell.updateUI(self.battle!)
            return cell
        } else if index == 1 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "commentsHeader", for: indexPath) as! CommentsHeaderTableViewCell
            return cell
        } else {
            let commentIndex = index - 2
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentsTableViewCell
            let nearEnd = (commentIndex > (self.comments.count * 3) / 4)
            let hasMore = (self.comments.count == self.currentPage * self.pageSize)
            if nearEnd && hasMore {
                self.currentPage += 1
                self.getComments(resetData: false) { success in
                }
            }
            cell.updateUI(self.comments[commentIndex])
            return cell
        }
    }
    
    // MARK: Notifications
    
    @objc func onRefresh(_ sender: Any) {
        self.getData(showSpinner: false)
    }
    
    @objc func onPostComment(_ sender: Any) {
        self.performSegue(withIdentifier: "postComment", sender: self)
    }
    
    // MARK: Private methods
    
    func getData(showSpinner: Bool) {
        if showSpinner {
            self.spinner!.start()
        }
        self.currentPage = 1
        self.getBattle() { success in
            if !success {
                if showSpinner {
                    self.spinner!.stop() {
                        self.refreshControl!.endRefreshing()
                        self.alert!.error("Failed to load Battle.")
                    }
                } else {
                    self.refreshControl!.endRefreshing()
                    self.alert!.error("Failed to load Battle.")
                }
            } else {
                self.getComments(resetData: true) { success in
                    if !success {
                        if showSpinner {
                            self.spinner!.stop() {
                                self.refreshControl!.endRefreshing()
                                self.alert!.error("Failed to load comments.")
                            }
                        } else {
                            self.refreshControl!.endRefreshing()
                            self.alert!.error("Failed to load comments.")
                        }
                    } else {
                        if showSpinner {
                            self.spinner!.stop() {
                                self.refreshControl!.endRefreshing()
                            }
                        } else {
                            self.refreshControl!.endRefreshing()
                        }
                    }
                }
            }
        }
    }
    
    func getBattle(completion: @escaping (Bool) -> Void) {
        API.instance.getBattleById(battleId: self.battleId!) { errorCode, battle in
            if errorCode != ErrorCode.none {
                completion(false)
            } else {
                self.battle = battle
                completion(true)
            }
        }
    }
    
    func getComments(resetData: Bool, completion: @escaping (Bool) -> Void) {
        if resetData {
            self.currentPage = 1
        }
        API.instance.getComments(battleId: self.battleId!, page: self.currentPage, pageSize: self.pageSize) { errorCode, comments in
            if errorCode != ErrorCode.none {
                completion(false)
            } else {
                if resetData {
                    self.comments = comments
                } else {
                    self.comments.append(contentsOf: comments)
                }
                self.tableView.reloadData()
                completion(true)
            }
        }
    }

}
