import UIKit

class AccountDetailsViewController: UIViewController {
    
    // MARK: Properties
    var spinner: Spinner?
    var yesNo: YesNo?
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner = Spinner(self)
        self.yesNo = YesNo(self)
    }

    // MARK: Actions
    
    @IBAction func deleteAccount(_ sender: Any) {
        self.yesNo!.show(title: "Confirm", message: "Are you sure you want to delete your account?") {
            uiAction in
            if uiAction.style == .default {
                self.spinner!.start()
                API.instance.deleteMyAccount() {
                    errorCode in
                    self.spinner!.stop() {
                        API.instance.logOut(sendNotification: true)
                    }
                }
            }
        }
        
    }
    
}
