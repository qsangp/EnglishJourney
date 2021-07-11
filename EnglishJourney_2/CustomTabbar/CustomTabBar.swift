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
    var tabBarHeight: CGFloat = 75.0
    var viewModel: CardViewModel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CardViewModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadTabBar), name: NSNotification.Name(rawValue: "PeformAfterPresenting"), object: nil)

        self.delegate = self
        self.selectedIndex = 0
        
        loadTabBar()
    }
    
    @objc func loadTabBar() {
        let tabbarItems: [TabItem] = [.home, .you]
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
        customTabBar.overrideUserInterfaceStyle = .light
        customTabBar.itemTapped = changeTab(tab:)
        view.addSubview(customTabBar)
        
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
    }
    
    func changeTab(tab: Int) {
        self.selectedIndex = tab
    }
    
}




