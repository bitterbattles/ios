import UIKit

class PostLoggedInViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    // MARK: Actions

    @IBAction func submit(_ sender: Any) {
        self.view.endEditing(true)
        if API.instance.isLoggedIn() {
            // TODO: Validate inputs
            // TODO: Start spinner
            let title = self.titleText.text ?? ""
            let description = self.descriptionText.text ?? ""
            API.instance.postBattle(title: title, description: description) { errorCode in
                // TODO: Stop spinner
                if errorCode == ErrorCode.none {
                    self.titleText.text = ""
                    self.descriptionText.text = ""
                    // TODO: Show success message
                } else {
                    // TODO: Show error message
                }
            }
        } else {
            // TODO: Redirect to register / log in
        }
    }
    
}
