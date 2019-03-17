import UIKit

class Alert {
    
    var parent: UIViewController
    
    init(_ parent: UIViewController) {
        self.parent = parent
    }
    
    func error(_ message: String) {
        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.parent.present(controller, animated: true)
    }
    
}
