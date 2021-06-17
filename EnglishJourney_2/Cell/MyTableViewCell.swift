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
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var lessonImage: UIImageView!
    
    var viewModel: CardViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel = CardViewModel()
    }
    
    let starImageOne: UIImageView = {
        let image = UIImageView.init(image: UIImage(named: "star"))
        return image
    }()
    let starImageTwo: UIImageView = {
        let image = UIImageView.init(image: UIImage(named: "star"))
        return image
    }()
    let starImageThree: UIImageView = {
        let image = UIImageView.init(image: UIImage(named: "star"))
        return image
    }()
    let starImageFour: UIImageView = {
        let image = UIImageView.init(image: UIImage(named: "star"))
        return image
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        numberLabel.text = ""
        statusLabel.text = ""
        statusLabel.isHidden = false
        statusLabel.backgroundColor = UIColor(red: 0.40, green: 0.78, blue: 0.73, alpha: 1.00)
        addStars(0)
    }
    
    func circleProgrress() {
        
        // Create track layer
        let trackLayer = CAShapeLayer()

        let center = progressView.center
        let circularPath = UIBezierPath(arcCenter: center, radius: 45, startAngle: -CGFloat.pi / 2, endAngle: 2*CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 10
        
        trackLayer.lineCap = .round
        progressView.layer.addSublayer(trackLayer)
        
        // Create shapeLayer
        let shapeLayer = CAShapeLayer()

        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 10
        
        shapeLayer.lineCap = .round
        
        shapeLayer.strokeEnd = 0
        progressView.layer.addSublayer(shapeLayer)
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        
        basicAnimation.duration = 2
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    func bindData(data: CardLessonItems, completionToday: Int, completionMonth: Int) {
        titleLabel.text = data.title.localizedCapitalized
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        let total = data.numOfLession
        numberLabel.text = "\(total) questions | This Month: \(completionMonth)"
        
        statusLabel.layer.masksToBounds = true
        statusLabel.layer.cornerRadius = 5
        
        if completionMonth >= 20 {
            statusLabel.isHidden = true
            addStars(4)
        } else if completionMonth >= 15 {
            statusLabel.isHidden = true
            addStars(3)
        } else if completionMonth >= 10 {
            statusLabel.isHidden = true
            addStars(2)
        } else if completionMonth >= 5 {
            statusLabel.isHidden = true
            addStars(1)
        } else if completionMonth == 0 || completionToday == 0 {
            statusLabel.backgroundColor = UIColor(red: 0.76, green: 0.35, blue: 0.34, alpha: 1.00)
        }
    }
    
    func addStars(_ numOfStar: Int) {

        view.addSubview(starImageOne)
        view.addSubview(starImageTwo)
        view.addSubview(starImageThree)
        view.addSubview(starImageFour)
        
        switch numOfStar {
        case 0:
            starImageFour.isHidden = true
            starImageThree.isHidden = true
            starImageTwo.isHidden = true
            starImageOne.isHidden = true
        case 1:
            starImageOne.isHidden = false
        case 2:
            starImageTwo.isHidden = false
            starImageOne.isHidden = false
        case 3:
            starImageThree.isHidden = false
            starImageTwo.isHidden = false
            starImageOne.isHidden = false
        default:
            starImageFour.isHidden = false
            starImageThree.isHidden = false
            starImageTwo.isHidden = false
            starImageOne.isHidden = false
        }

        starImageOne.translatesAutoresizingMaskIntoConstraints = false
        starImageTwo.translatesAutoresizingMaskIntoConstraints = false
        starImageThree.translatesAutoresizingMaskIntoConstraints = false
        starImageFour.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            starImageOne.widthAnchor.constraint(equalToConstant: 30),
            starImageOne.heightAnchor.constraint(equalToConstant: 30),
            starImageOne.leftAnchor.constraint(equalTo: statusLabel.leftAnchor, constant: 0),
            starImageOne.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            starImageTwo.widthAnchor.constraint(equalToConstant: 30),
            starImageTwo.heightAnchor.constraint(equalToConstant: 30),
            starImageTwo.leftAnchor.constraint(equalTo: starImageOne.rightAnchor, constant: 5),
            starImageTwo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            starImageThree.widthAnchor.constraint(equalToConstant: 30),
            starImageThree.heightAnchor.constraint(equalToConstant: 30),
            starImageThree.leftAnchor.constraint(equalTo: starImageTwo.rightAnchor, constant: 5),
            starImageThree.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            starImageFour.widthAnchor.constraint(equalToConstant: 30),
            starImageFour.heightAnchor.constraint(equalToConstant: 30),
            starImageFour.leftAnchor.constraint(equalTo: starImageThree.rightAnchor, constant: 5),
            starImageFour.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
