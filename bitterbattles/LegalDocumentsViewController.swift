import UIKit
import WebKit

class LegalDocumentsViewController: UIViewController, WKUIDelegate {
    
    // MARK: Properties
    
    var webView: WKWebView!
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://dev.bitterbattles.com/legal.html")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

}
