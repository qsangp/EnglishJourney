//
//  TabbarItems.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 02/06/2021.
//

import UIKit

enum TabItem: String, CaseIterable {
    case lesson = "lesson"
    case chart = "chart"

    var viewController: UIViewController {
        switch self {
        case .lesson:
            return ViewController()
        case .chart:
            return ChartVC()
        }
    }

    var icon: UIImage {
        switch self {
        case .lesson:
            return UIImage(named: "tabBarIcon1Colored")!
        case .chart:
            return UIImage(named: "tabBarIcon2Colored")!
        }
    }
    
    var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}
