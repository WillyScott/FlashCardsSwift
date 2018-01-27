//
//  SetTableViewCell.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 3/1/17.
// //

import UIKit

class SetTableViewCell: UITableViewCell {
    
    
    static let  reuseIdentifier = "SetCell"
    
    @IBOutlet weak var setLabel: UILabel!
    @IBOutlet weak var setDescription: UILabel!
    @IBOutlet weak var cardsLabel: UILabel!
    @IBOutlet weak var setSection: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
 
