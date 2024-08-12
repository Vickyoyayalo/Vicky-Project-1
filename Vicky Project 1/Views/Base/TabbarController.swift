//
//  TabbarController.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/8/8.
//

import UIKit

class TabbarController: UITabBarController, UITabBarControllerDelegate, UIViewControllerTransitioningDelegate {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(loadCartItems), name: .cartUpdated, object: nil)
        
        updateCartBadge()
    }
    
    // MARK: - Notification Handlers
    
    @objc func loadCartItems() {
        updateCartBadge()
    }
    
    // MARK: - Badge Handling
    
    func updateCartBadge() {
        let cartItems = StorageManager.shared.fetchCartItems()
        let totalQuantity = cartItems.reduce(0) { $0 + (Int($1.quantity ?? "0") ?? 0) }
        
        if let cartTabBarItem = tabBar.items?[2] {
            cartTabBarItem.badgeValue = totalQuantity > 0 ? "\(totalQuantity)" : nil
        }
    }
    
    // MARK: - Tab Bar Delegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController), index == 2 || index == 3 {
            if checkLoginStatus() {
                return true
            } else {
                presentLoginIfNeeded()
                return false
            }
        }
        return true
    }
    
    // MARK: - Login Handling
    
    func presentLoginIfNeeded() {
        let isLoggedIn = checkLoginStatus()
        
        if !isLoggedIn {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                loginViewController.modalPresentationStyle = .custom
                loginViewController.transitioningDelegate = self
                
                self.present(loginViewController, animated: true, completion: nil)
            }
        }
    }

    // MARK: - Custom Presentation Delegate
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    // MARK: - Helper Methods
    
    func checkLoginStatus() -> Bool {
        if let token = UserDefaults.standard.string(forKey: "STYLiSHToken") {
            return !token.isEmpty
        }
        return false
    }
}
