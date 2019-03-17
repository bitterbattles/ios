import UIKit

class Alert {
    
    var parent: UIViewController
    
    init(_ parent: UIViewController) {
        self.parent = parent
    }
    
    func error(_ message: String) {
        self.alert(title: "Error", message: message, completion: nil)
    }
    
    func success(_ message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        self.alert(title: "Success", message: message, completion: completion)
    }
    
    func alert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: completion))
        self.parent.present(controller, animated: true)
    }
    
}
