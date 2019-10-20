import UIKit

class PostViewController: UIViewController, UITextViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    var placeholderLabel: UILabel!
    var spinner: Spinner?
    var alert: Alert?
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner = Spinner(self)
        self.alert = Alert(self)
        self.descriptionText.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Description"
        placeholderLabel.font = UIFont.systemFont(ofSize: (descriptionText.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        descriptionText.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionText.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.systemGray2.withAlphaComponent(0.6)
        placeholderLabel.isHidden = !descriptionText.text.isEmpty
        self.descriptionText.layer.cornerRadius = 5
        self.descriptionText.layer.borderColor = UIColor.systemGray2.withAlphaComponent(0.3).cgColor
        self.descriptionText.layer.borderWidth = 0.8
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
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
