//
//  HomeVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 13/06/2021.
//

import UIKit

class HomeVC: UIViewController {

    deinit {
        print("HomeVC has no retain cycle")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

    }
}
