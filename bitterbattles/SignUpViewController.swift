import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
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
        let presentingController = self.navigationController?.presentingViewController as? TabBarController
        if presentingController == nil {
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
    
    @IBAction func signUp(_ sender: Any) {
        self.view.endEditing(true)
        let username = self.usernameText.text ?? ""
        let password = self.passwordText.text ?? ""
        if username.count < 4 || username.count > 20 || password.count < 8 || password.count > 24 || username.range(of: "^[a-zA-Z][a-zA-Z0-9]*$", options: .regularExpression) == nil || password.range(of: "(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*#?&])", options: .regularExpression) == nil {
            self.alert!.error("Invalid input fields.")
            return
        }
        self.spinner!.start()
        API.instance.signUp(username: username, password: password) { errorCode in
            if errorCode == ErrorCode.none {
                API.instance.logIn(username: username, password: password) { errorCode in
                    self.usernameText.text = ""
                    self.passwordText.text = ""
                    self.spinner!.stop() {
                        if errorCode == ErrorCode.none {
                            self.alert!.success("Sign up successful.") { aciton in
                                self.dismiss(animated: true)
                            }
                        } else {
                            self.alert!.error("Sign up failed.")
                        }
                    }
                }
            } else {
                self.spinner!.stop() {
                    if errorCode == ErrorCode.usernameTaken {
                        self.alert!.error("Username is already taken.")
                    } else {
                        self.alert!.error("Sign up failed.")
                    }
                }
            }
        }
    }
    
}
