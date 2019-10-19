import UIKit

class CommentsTableViewController: UITableViewController {
    
    // MARK - Properties
    
    var spinner: Spinner?
    var alert: Alert?
    var yesNo: YesNo?
    var currentPage = 1
    let pageSize = 25
    var comments = [Comment]()
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl!)
        self.refreshControl!.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)
        self.spinner = Spinner(self)
        self.alert = Alert(self)
        self.yesNo = YesNo(self)
        self.tableView.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "comment")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.comments.count == 0 {
            self.getComments(resetData: true, showSpinner: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as? BattleDetailsViewController
        if viewController != nil {
            let index = self.tableView.indexPathForSelectedRow!.row
            let comment = self.comments[index]
            viewController!.battleId = comment.battleId
        }
    }
    
    // MARK: Table view data
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "comment", for: indexPath) as! CommentsTableViewCell
        let nearEnd = (index > (self.comments.count * 3) / 4)
        let hasMore = (self.comments.count == self.currentPage * self.pageSize)
        if nearEnd && hasMore {
            self.currentPage += 1
            self.getComments(resetData: false, showSpinner: false)
        }
        cell.updateUI(self.comments[index])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.yesNo!.show(title: "Confirm", message: "Are you sure you want to delete this comment?") {
                uiAction in
                if uiAction.style == .default {
                    self.spinner!.start()
                    let index = indexPath.row
                    let comment = self.comments[index]
                    API.instance.deleteMyComment(commentId: comment.id) {
                        errorCode in
                        self.spinner!.stop() {
                            self.comments.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "commentSelected", sender: self)
    }
    
    // MARK: Notifications
    
    @objc func onRefresh(_ sender: Any) {
        self.getComments(resetData: true, showSpinner: false)
    }
    
    // MARK: Private methods
    
    func getComments(resetData: Bool, showSpinner: Bool) {
        if showSpinner {
            self.spinner!.start()
        }
        if resetData {
            self.currentPage = 1
        }
        API.instance.getMyComments(page: self.currentPage, pageSize: self.pageSize) { errorCode, comments in
            if resetData {
                self.comments = comments
            } else {
                self.comments.append(contentsOf: comments)
            }
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
            if showSpinner {
                self.spinner!.stop() {
                    if errorCode != ErrorCode.none {
                        self.alert!.error("Failed to load Comments.")
                    }
                }
            }
        }
    }

}
