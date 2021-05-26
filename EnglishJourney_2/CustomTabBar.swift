//
//  CustomTabBar.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//


import Foundation
import UIKit

class CustomTabBarVC: UITabBarController, UITabBarControllerDelegate {
    
    var leftLabel: UILabel!
    var rightLabel: UILabel!
    
    var leftButton: UIButton!
    var rightButton: UIButton!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.selectedIndex = 0

        setupLeftButton()
        setupRightButton()

    }
    
    func setupLeftButton() {
        self.leftButton = UIButton(frame: CGRect(x: self.view.bounds.width / 5, y: 5, width: 40, height: 40))
        
        self.leftLabel = UILabel(frame: CGRect(x: self.view.bounds.width / 5.4, y: 34, width: 120, height: 40))
        
        leftLabel.text = "Lessons"
        leftLabel.font = leftLabel.font.withSize(14)
        
        leftButton.setBackgroundImage(UIImage(named: "tabBarIcon1Colored"), for: .normal)
        
        self.tabBar.addSubview(leftButton)
        self.tabBar.addSubview(leftLabel)
        
        leftButton.addTarget(self, action: #selector(leftButtonAction), for: .touchUpInside)
        
        self.view.layoutIfNeeded()
        
    }
    
    @objc func leftButtonAction(sender: UIButton) {
        self.selectedIndex = 0
        
        leftButton.setBackgroundImage(UIImage(named: "tabBarIcon1Colored"), for: .normal)
        
        rightButton.setBackgroundImage(UIImage(named: "tabBarIcon2"), for: .normal)
        
    }
    
    func setupRightButton() {
        self.rightButton = UIButton(frame: CGRect(x: 290, y: 0, width: 40, height: 40))
        
        self.rightLabel = UILabel(frame: CGRect(x: 290, y: 27, width: 120, height: 40))
        
        rightLabel.text = "Chart"
        rightLabel.font = rightLabel.font.withSize(14)
        
        rightButton.setBackgroundImage(UIImage(named: "tabBarIcon2"), for: .normal)
        
        self.tabBar.addSubview(rightButton)
        self.tabBar.addSubview(rightLabel)
        
        rightButton.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        
        self.view.layoutIfNeeded()
    }
    
    @objc func rightButtonAction(sender: UIButton) {
        self.selectedIndex = 1
        
        self.leftButton.setBackgroundImage(UIImage(named: "tabBarIcon1"), for: .normal)
        
        self.rightButton.setBackgroundImage(UIImage(named: "tabBarIcon2Colored"), for: .normal)
    }
}




