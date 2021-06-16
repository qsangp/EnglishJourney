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
    var numOfComplete = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel = CardViewModel()
        setUpUI()
    }
    
    func setUpUI() {
        view.backgroundColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        numberLabel.text = "\(total) questions"
        
        statusLabel.text = "Today: \(completionToday) | Total: \(completionMonth)"
        
        if completionMonth >= 5 || completionToday > 0 {
            statusLabel.backgroundColor = UIColor(red: 0.40, green: 0.78, blue: 0.73, alpha: 1.00)
        } else {
            statusLabel.backgroundColor = UIColor(red: 0.76, green: 0.35, blue: 0.34, alpha: 1.00)
        }
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
