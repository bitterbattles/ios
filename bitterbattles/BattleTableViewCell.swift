//
//  BattleTableViewCell.swift
//  bitterbattles
//
//  Created by Adam Lupinacci on 2/25/19.
//  Copyright © 2019 Little Wolf Software. All rights reserved.
//

import UIKit

class BattleTableViewCell: UITableViewCell {
    
    //MARK: Properties
    public var id: String?
    public var votesFor: Int?
    public var votesAgainst: Int?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var votesForLabel: UILabel!
    @IBOutlet weak var votesAgainstLabel: UILabel!
    @IBOutlet weak var voteForButton: UIButton!
    @IBOutlet weak var voteAgainstButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func voteFor(_ sender: Any) {
        vote(isFor: true)
        votesFor = (votesFor ?? 0) + 1
        votesForLabel.text = String(votesFor ?? 0)
    }
    
    @IBAction func voteAgainst(_ sender: Any) {
        vote(isFor: false)
        votesAgainst = (votesAgainst ?? 0) + 1
        votesAgainstLabel.text = String(votesAgainst ?? 0)
    }
    
    func vote(isFor: Bool) {
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let url = URL(string: "https://api-dev.bitterbattles.com/v1/votes")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = "{\"battleId\":\"\(id ?? "")\",\"isVoteFor\":\(isFor)}"
        request.httpBody = body.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
        })
        task.resume()
    }
    
}
