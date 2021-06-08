//
//  TabbarItems.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 02/06/2021.
//

import UIKit

enum TabItem: String, CaseIterable {
    case lesson = "lesson"
    case home = "home"
    case progress = "progress"

    var viewController: UIViewController {
        switch self {
        case .lesson:
            return ViewController()
        case .home:
            return ScheduleVC()
        case .progress:
            return ChartVC()
        }
    }

    var icon: UIImage {
        switch self {
        case .lesson:
            return UIImage(systemName: "book.fill")!
        case .home:
            return UIImage(systemName: "house.fill")!
        case .progress:
            return UIImage(systemName: "chart.bar.fill")!
        }
    }
    
    var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}
