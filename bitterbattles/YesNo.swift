import UIKit

class YesNo {
    
    var parent: UIViewController
    
    init(_ parent: UIViewController) {
        self.parent = parent
    }
    
    func show(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "No", style: .cancel, handler: completion))
        controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: completion))
        self.parent.present(controller, animated: true)
    }
    
}
