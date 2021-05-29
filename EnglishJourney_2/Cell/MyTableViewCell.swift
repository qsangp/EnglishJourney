//
//  MyTableViewCell.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var cellBody: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellBody.layer.cornerRadius = 15
        cellBody.backgroundColor = UIColor.random()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
            alpha: 0.4
        )
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
