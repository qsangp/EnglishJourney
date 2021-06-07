//
//  TabbarItems.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 02/06/2021.
//

import UIKit

enum TabItem: String, CaseIterable {
    case lesson = "lesson"
    case schedule = "schedule"
    case chart = "chart"

    var viewController: UIViewController {
        switch self {
        case .lesson:
            return ViewController()
        case .schedule:
            return ScheduleVC()
        case .chart:
            return ChartVC()
        }
    }

    var icon: UIImage {
        switch self {
        case .lesson:
            return UIImage(named: "tabbarIcon1Colored")!
        case .schedule:
            return UIImage(named: "tabbarIcon3Colored")!
        case .chart:
            return UIImage(named: "tabBarIcon2Colored")!
        }
    }
    
    var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}
