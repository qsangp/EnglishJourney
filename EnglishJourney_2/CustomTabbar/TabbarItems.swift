//
//  TabbarItems.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 02/06/2021.
//

import UIKit

enum TabItem: String, CaseIterable {
    case home = "home"
    case you = "you"

    var viewController: UIViewController {
        switch self {
        case .home:
            return HomeViewController()
        case .you:
            return UserProfileVC()
        }
    }

    var icon: UIImage {
        switch self {
        case .home:
            return UIImage.init(systemName: "house")!
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




