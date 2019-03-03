//
//  Battle.swift
//  bitterbattles
//
//  Created by Adam Lupinacci on 2/26/19.
//  Copyright © 2019 Little Wolf Software. All rights reserved.
//

import UIKit

class Battle {
    
    //MARK: Properties
    
    var id: String
    var title: String
    var description: String
    var votesFor: Int
    var votesAgainst: Int
    var createdOn: Int64
    
    //MARK: Initialization
    
    init(id: String, title: String, description: String, votesFor: Int, votesAgainst: Int, createdOn: Int64) {
        self.id = id
        self.title = title
        self.description = description
        self.votesFor = votesFor
        self.votesAgainst = votesAgainst
        self.createdOn = createdOn
    }
    
}
