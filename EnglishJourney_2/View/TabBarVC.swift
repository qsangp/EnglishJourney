//
//  TabBarVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 02/06/2021.
//

import UIKit

class TabBarVC: UITabBar {
    
    @IBInspectable var height: CGFloat = 60.0
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeOfTab = super.sizeThatFits(size)
        if height > 0.0 {
            sizeOfTab.height = height
        }
        return sizeOfTab
    }
}
