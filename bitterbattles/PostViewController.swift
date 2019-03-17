import UIKit

class PostViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    var spinner: Spinner?
    var alert: Alert?
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner = Spinner(self)
        self.alert = Alert(self)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    // MARK: Actions

    @IBAction func submit(_ sender: Any) {
        self.view.endEditing(true)
        if API.instance.isLoggedIn() {
            let title = self.titleText.text ?? ""
            let description = self.descriptionText.text ?? ""
            if title.count < 4 || title.count > 50 || description.count < 4 || description.count > 500 {
                self.alert!.error("The input fields are not valid.")
                return
            }
            self.spinner!.start()
            API.instance.postBattle(title: title, description: description) { errorCode in
                if errorCode == ErrorCode.none {
                    self.titleText.text = ""
                    self.descriptionText.text = ""
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "battlePosted"), object: nil)
                }
                self.spinner!.stop() {
                    if errorCode == ErrorCode.none {
                        self.alert!.success("Battle successfully posted.")
                    } else {
                        self.alert!.error("Failed to post the Battle.")
                    }
                }
            }
        }
    }
    
}
