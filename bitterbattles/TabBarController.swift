import UIKit

class TabBarController: UITabBarController {
    
    // MARK: Properties

    var unusedPostController: UIViewController? = nil
    var unusedAccountController: UIViewController? = nil

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        var viewControllers = self.viewControllers!
        if API.instance.isLoggedIn() {
            self.unusedPostController = viewControllers.remove(at: 1)
            self.unusedAccountController = viewControllers.remove(at: 2)
        } else {
            self.unusedPostController = viewControllers.remove(at: 2)
            self.unusedAccountController = viewControllers.remove(at: 3)
        }
        self.setViewControllers(viewControllers, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoginChanged(_:)), name: NSNotification.Name(rawValue: "loggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoginChanged(_:)), name: NSNotification.Name(rawValue: "loggedOut"), object: nil)
    }

    // MARK: Notifications

    @objc func onLoginChanged(_ notification: Notification) {
        var viewControllers = self.viewControllers!
        let tempPostController = viewControllers.remove(at: 1)
        let tempAccountController = viewControllers.remove(at: 1)
        viewControllers.append(self.unusedPostController!)
        viewControllers.append(self.unusedAccountController!)
        self.setViewControllers(viewControllers, animated: false)
        self.unusedPostController = tempPostController
        self.unusedAccountController = tempAccountController
    }

}
