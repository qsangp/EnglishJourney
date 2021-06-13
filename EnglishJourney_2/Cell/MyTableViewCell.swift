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
    @IBOutlet weak var cell_image: UIImageView!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    func setUpUI() {
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor.random()
        cell_image.layer.cornerRadius = 10
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor(red: 0.81, green: 0.82, blue: 0.83, alpha: 1.00).cgColor
        
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
            alpha: 0.3
        )
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
