//
//  CustomTabBar.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//


import Foundation
import UIKit

class CustomTabBarVC: UITabBarController, UITabBarControllerDelegate {
    
    var customTabBar: CustomTabbarUIView!
    var tabBarHeight: CGFloat = 60.0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.selectedIndex = 0
        
        UITabBar.appearance().barTintColor = UIColor.white
        loadTabBar()
    }
    
    func loadTabBar() {
        let tabbarItems: [TabItem] = [.lesson, .progress, .home, .others]
        
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
            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Thêm các view controller tương ứng
        menuItems.forEach({
            controllers.append($0.viewController)
        })

        view.layoutIfNeeded()
    }
    
    func changeTab(tab: Int) {
        self.selectedIndex = tab
    }
    
}




