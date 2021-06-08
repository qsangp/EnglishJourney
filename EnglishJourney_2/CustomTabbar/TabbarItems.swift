//
//  TabbarItems.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 02/06/2021.
//

import UIKit

enum TabItem: String, CaseIterable {
    case lesson = "bài học"
    case home = "trang chủ"
    case progress = "tiến độ"
    case others = "khác"

    var viewController: UIViewController {
        switch self {
        case .lesson:
            return ViewController()
        case .home:
            return ScheduleVC()
        case .progress:
            return ChartVC()
        case .others:
            return UserProfileVC()
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
        case .others:
            return UIImage(systemName: "gearshape.fill")!
        }
    }
    
    var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}
