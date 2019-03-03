//
//  SecondViewController.swift
//  bitterbattles
//
//  Created by Adam Lupinacci on 2/21/19.
//  Copyright © 2019 Little Wolf Software. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descriptionText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func submit(_ sender: Any) {
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let url = URL(string: "https://api-dev.bitterbattles.com/v1/battles")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = "{\"title\":\"\(titleText.text ?? "")\",\"description\":\"\(descriptionText.text ?? "")\"}"
        request.httpBody = body.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
        })
        task.resume()
    }
    
}

