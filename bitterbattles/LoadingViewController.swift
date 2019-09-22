import UIKit

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        API.instance.refreshLogin(sendNotification: false) {
            self.performSegue(withIdentifier: "loadingComplete", sender: self)
        }
    }

}
