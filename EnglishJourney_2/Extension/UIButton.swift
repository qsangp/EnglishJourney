//
//  UIButton.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 30/05/2021.
//

import Foundation
import UIKit

extension UIButton {
    func preventRepeatedPresses(inNext seconds: Double = 1) {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            self.isUserInteractionEnabled = true
        }
    }
}
