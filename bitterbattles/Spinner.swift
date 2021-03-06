import UIKit

class Spinner {
    
    var parent: UIViewController
    var controller: UIAlertController
    var isVisible: Bool
    
    init(_ parent: UIViewController) {
        self.parent = parent
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        indicator.hidesWhenStopped = true
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.startAnimating()
        self.controller = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        self.controller.view.addSubview(indicator)
        self.isVisible = false
    }
    
    func start() {
        if !self.isVisible {
            self.parent.present(self.controller, animated: false, completion: nil)
            self.isVisible = true
        }
    }
    
    func stop(_ completion: @escaping () -> Void) {
        if self.isVisible {
            self.controller.dismiss(animated: false, completion: completion)
            self.isVisible = false
        }
    }
    
}
