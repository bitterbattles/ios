import UIKit

class Spinner {
    
    var parent: UIViewController
    var controller: UIAlertController
    
    init(_ parent: UIViewController) {
        self.parent = parent
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        indicator.hidesWhenStopped = true
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.startAnimating()
        self.controller = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        self.controller.view.addSubview(indicator)
    }
    
    func start() {
        self.parent.present(self.controller, animated: true, completion: nil)
    }
    
    func stop(_ completion: @escaping () -> Void) {
        self.controller.dismiss(animated: true, completion: completion)
    }
    
}
