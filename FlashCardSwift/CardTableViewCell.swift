//
//  CardTableViewCell.swift
//  FlashCardSwift
//
//  Created by Scott Gromme on 3/21/17.
//  //

import UIKit

class CardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var frontCard: UILabel!
    @IBOutlet weak var backCard: UILabel!
    @IBOutlet weak var showCard: UILabel!
    static var reuseIdentifier = "CardCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
