//
//  TabbarItems.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 02/06/2021.
//

import UIKit

enum TabItem: String, CaseIterable {
    case lesson = "bài học"
//    case home = "trang chủ"
    case progress = "tiến độ"
    case you = "bạn"

    var viewController: UIViewController {
        switch self {
        case .lesson:
            return ViewController()
//        case .home:
//            return HomeVC()
        case .progress:
            return ChartVC()
        case .you:
            return UserProfileVC()
        }
    }

    var icon: UIImage {
        switch self {
        case .lesson:
            return UIImage(named: "tabbarIcon1Colored")!
//        case .home:
//            return UIImage(systemName: "house.fill")!
        case .progress:
            return UIImage(named: "tabBarIcon2Colored")!
        case .you:
            var profileImage = UIImage()
            guard let url = UserDefaults.standard.url(forKey: "userImageURL") else {return profileImage}
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async {
                    profileImage = image
                }
            }.resume()
            return profileImage
        }
    }
    
    var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}




