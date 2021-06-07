//
//  BaseTabBarController.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 02/06/2021.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    var customTabBar: CustomTabbarUIView!
    var tabBarHeight: CGFloat = 67.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabBar()
    }
    
    func loadTabBar() {
        let tabbarItems: [TabItem] = [.lesson, .schedule, .chart]

                setupCustomTabMenu(tabbarItems, completion: { viewControllers in
                    self.viewControllers = viewControllers
                })
                selectedIndex = 0
    }
    
    func setupCustomTabMenu(_ menuItems: [TabItem], completion: @escaping ([UIViewController]) -> Void) {
        let frame = tabBar.frame
                var controllers = [UIViewController]()

                // Ẩn tab bar mặc định của hệ thống đi
                tabBar.isHidden = true
                // Khởi tạo custom tab bar
                customTabBar = CustomTabbarUIView(menuItems: menuItems, frame: frame)
                customTabBar.translatesAutoresizingMaskIntoConstraints = false
                customTabBar.clipsToBounds = true
                customTabBar.itemTapped = changeTab(tab:)
                view.addSubview(customTabBar)
                view.backgroundColor = .white

                // Auto layout cho custom tab bar
                NSLayoutConstraint.activate([
                    customTabBar.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
                    customTabBar.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
                    customTabBar.widthAnchor.constraint(equalToConstant: tabBar.frame.width),
                    customTabBar.heightAnchor.constraint(equalToConstant: tabBarHeight),
                    customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])

                // Thêm các view controller tương ứng
                menuItems.forEach({
                    controllers.append($0.viewController)
                })

                view.layoutIfNeeded()
                completion(controllers)
    }
    
    func changeTab(tab: Int) {
        self.selectedIndex = tab
    }
}

