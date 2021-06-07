//
//  RandomQuestionViewCell.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 06/06/2021.
//

import UIKit

class RandomQuestionViewCell: UITableViewCell {
    
    @IBOutlet weak var greetView: UIView!
    @IBOutlet weak var greetMessage: UILabel!
    @IBOutlet weak var randomButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        greetView.layer.cornerRadius = 20
        greetMessage.text = "What do we learn today?"
        randomButton.layer.cornerRadius = 10
        randomButton.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
