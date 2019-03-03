//
//  FirstViewController.swift
//  bitterbattles
//
//  Created by Adam Lupinacci on 2/21/19.
//  Copyright © 2019 Little Wolf Software. All rights reserved.
//

import UIKit

class FirstViewController: UITableViewController  {
    
    //MARK: Properties
    
    var battles = [Battle]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBattles(sort: "recent") { battles in
            self.battles = battles
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return battles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "BattleTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BattleTableViewCell  else {
            fatalError("The dequeued cell is not an instance of BattleTableViewCell.")
        }
        
        // Fetches the appropriate battle for the data source layout.
        let battle = battles[indexPath.row]
        
        cell.id = battle.id
        cell.votesFor = battle.votesFor
        cell.votesAgainst = battle.votesAgainst
        cell.titleLabel.text = battle.title
        cell.createdOnLabel.text = String(battle.createdOn)
        cell.descriptionLabel.text = battle.description
        cell.votesForLabel.text = String(battle.votesFor)
        cell.votesAgainstLabel.text = String(battle.votesAgainst)
        
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: Private Methods
    
    private func loadBattles(sort: String, completion: @escaping ([Battle]) -> Void) {
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: .main)
        let url = URL(string: "https://api-dev.bitterbattles.com/v1/battles?sort=\(sort)")!
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            var battles :[Battle] = []
            if let data = data, let results = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                for case let result in results ?? [] {
                    let id = result["id"] as? String ?? ""
                    let title = result["title"] as? String ?? ""
                    let description = result["description"] as? String ?? ""
                    let votesFor = result["votesFor"] as? Int ?? 0
                    let votesAgainst = result["votesAgainst"] as? Int ?? 0
                    let createdOn = result["createdOn"] as? Int64 ?? 0
                    let battle = Battle(id: id, title: title, description: description, votesFor: votesFor, votesAgainst: votesAgainst, createdOn: createdOn)
                    battles.append(battle)
                }
            }
            completion(battles)
        })
        task.resume()
    }
    
    @IBAction func loadRecent(_ sender: Any) {
        loadBattles(sort: "recent") { battles in
            self.battles = battles
            self.tableView.reloadData()
        }
    }
    
    @IBAction func loadPopular(_ sender: Any) {
        loadBattles(sort: "popular") { battles in
            self.battles = battles
            self.tableView.reloadData()
        }
    }
    
    @IBAction func loadControversial(_ sender: Any) {
        loadBattles(sort: "controversial") { battles in
            self.battles = battles
            self.tableView.reloadData()
        }
    }
    
}

