import UIKit

class PostCommentViewController: UIViewController, UITextViewDelegate {

    // MARK: Properties

    @IBOutlet weak var commentText: UITextView!
    var placeholderLabel: UILabel!
    var spinner: Spinner?
    var alert: Alert?
    var battleId: String?

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner = Spinner(self)
        self.alert = Alert(self)
        self.commentText.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Comment"
        placeholderLabel.font = UIFont.systemFont(ofSize: (commentText.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        commentText.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (commentText.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray.withAlphaComponent(0.5)
        placeholderLabel.isHidden = !commentText.text.isEmpty
        self.commentText.layer.cornerRadius = 5
        self.commentText.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        self.commentText.layer.borderWidth = 1
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    // MARK: Actions

    @IBAction func submit(_ sender: Any) {
        self.view.endEditing(true)
        if API.instance.isLoggedIn() {
            let comment = self.commentText.text ?? ""
            if comment.count < 4 || comment.count > 500 {
                self.alert!.error("The input fields are not valid.")
                return
            }
            self.spinner!.start()
            API.instance.postComment(battleId: self.battleId!, comment: comment) { errorCode in
                if errorCode == ErrorCode.none {
                    self.commentText.text = ""
                }
                self.spinner!.stop() {
                    if errorCode == ErrorCode.none {
                        self.alert!.success("Comment successfully created.")
                    } else {
                        self.alert!.error("Failed to create the comment.")
                    }
                }
            }
        }
    }

}
