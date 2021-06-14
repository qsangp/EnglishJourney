//
//  CategoryTableVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 14/06/2021.
//

import UIKit

class CategoryTableVC: UITableViewCell {
    @IBOutlet weak var cell_image: UIImageView!
    @IBOutlet weak var cell_left_label: UILabel!
    @IBOutlet weak var cell_right_label: UILabel!
    @IBOutlet weak var text_view: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
