import UIKit

class LogInViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    var spinner: Spinner?
    var alert: Alert?
    var cancelItem: UIBarButtonItem?
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner = Spinner(self)
        self.alert = Alert(self)
        self.cancelItem = self.navigationItem.rightBarButtonItem
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController?.presentingViewController == nil {
            if self.navigationItem.rightBarButtonItem != nil {
                self.navigationItem.rightBarButtonItem = nil
            }
        } else {
            if self.navigationItem.rightBarButtonItem == nil {
                self.navigationItem.rightBarButtonItem = self.cancelItem
            }
        }
    }
    
    // MARK: Actions

    @IBAction func cancel(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logIn(_ sender: Any) {
        self.view.endEditing(true)
        let username = self.usernameText.text ?? ""
        let password = self.passwordText.text ?? ""
        if username.count == 0 || password.count == 0 {
            self.alert!.error("Input fields are invalid.")
            return
        }
        self.spinner!.start()
        API.instance.logIn(username: username, password: password) { errorCode in
            if errorCode == ErrorCode.none {
                self.usernameText.text = ""
                self.passwordText.text = ""
            } else {
                self.passwordText.text = ""
            }
            self.spinner!.stop() {
                if errorCode == ErrorCode.none {
                    self.alert!.success("Login successful.") { action in
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self.alert!.error("Invalid credentials.")
                }
            }
        }
    }
    
}
