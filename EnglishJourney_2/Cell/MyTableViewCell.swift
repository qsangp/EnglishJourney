//
//  MyTableViewCell.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import UIKit
import Kingfisher

class MyTableViewCell: UITableViewCell {
    
    var viewModel: CardViewModel!
        
    let thumbnailCell: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    let titleLable: UILabel = {
        let title = UILabel()
        title.sizeToFit()
        title.text = ""
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.numberOfLines = 0
        return title
    }()
    
    let descriptionLabel: UILabel = {
        let title = UILabel()
        title.text = ""
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.numberOfLines = 0
        return title
    }()
    
    let secondTitleLable: UILabel = {
        let title = UILabel()
        title.sizeToFit()
        title.text = ""
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        title.textColor = UIColor.systemGray
        title.numberOfLines = 0
        return title
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupLessonCell() {
        
        contentView.addSubview(thumbnailCell)
        thumbnailCell.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
        thumbnailCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        thumbnailCell.widthAnchor.constraint(equalToConstant: 150).isActive = true
        thumbnailCell.heightAnchor.constraint(equalToConstant: contentView.frame.width/2.5).isActive = true
        thumbnailCell.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor).isActive = true
        
        contentView.addSubview(titleLable)
        titleLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLable.leadingAnchor.constraint(equalTo: thumbnailCell.trailingAnchor, constant: 15).isActive = true
        titleLable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        
        contentView.addSubview(secondTitleLable)
        secondTitleLable.topAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: -5).isActive = true
        secondTitleLable.leadingAnchor.constraint(equalTo: thumbnailCell.trailingAnchor, constant: 15).isActive = true
        secondTitleLable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        secondTitleLable.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
    }
    
    func setupNoCardReviewCell() {
        contentView.addSubview(descriptionLabel)
        descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        descriptionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 5).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        descriptionLabel.text = "You have no recently learned card to review"
        descriptionLabel.textColor = UIColor.systemGray
        descriptionLabel.layer.borderWidth = 0.5
        descriptionLabel.layer.borderColor = UIColor.systemGray.cgColor
        descriptionLabel.layer.cornerRadius = 5
        descriptionLabel.textAlignment = .center
    }    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailCell.image = UIImage()
        titleLable.text = ""
        descriptionLabel.text = ""
        secondTitleLable.text = ""
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
    }
    
    func bindData(data: CardCategoryItems) {
        let str = data.title
        let start = str.index(str.startIndex, offsetBy: 3)
        let end = str.index(str.endIndex, offsetBy: 0)
        let range = start..<end
        let title = str[range]
        
        guard data.numOfLession > 0 else {return}
        titleLable.text = "\(title.localizedCapitalized)"
        
        if data.numOfLession > 0 {
            let completionMonth = viewModel.numberOfCompletionMonth(cardId: data.id)
            secondTitleLable.text = "\(data.numOfLession) lessons - Completed: \(completionMonth / data.numOfLession)"
        }
        
        let urlFile = title.localizedLowercase.replacingOccurrences(of: " ", with: "-")
        guard let url = URL(string: "https://app.ielts-vuive.com/data/lesson/image/\(urlFile)-01.jpg?v=") else {return}
        
        viewModel.saveCardThumbnailImage(cardId: data.id, url: url)

        let resource = ImageResource(downloadURL: url, cacheKey: urlFile)
        thumbnailCell.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.2))])
    }
    
    func bindDataToReview(data: CardCategoryItems) {
        let str = data.title
        let start = str.index(str.startIndex, offsetBy: 3)
        let end = str.index(str.endIndex, offsetBy: 0)
        let range = start..<end
        let title = str[range]
        
        guard data.numOfLession > 0 else {return}
        titleLable.text = "\(title.localizedCapitalized)"
        
        let urlFile = title.localizedLowercase.replacingOccurrences(of: " ", with: "-")
        guard let url = URL(string: "https://app.ielts-vuive.com/data/lesson/image/\(urlFile)-01.jpg?v=") else {return}
        
        let resource = ImageResource(downloadURL: url, cacheKey: urlFile)
        thumbnailCell.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.2))])
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
